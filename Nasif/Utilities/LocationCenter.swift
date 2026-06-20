//
//  LocationCenter.swift
//  Nasif
//
//  Created by Denish Gediya on 02/07/25.
//

import UIKit
import CoreLocation
import GoogleMaps
import GooglePlaces

struct PlaceDetails {
    var country: String
    var isoCountryCode: String
    var locality: String
}

typealias TimeDistanceAPICompletion = ((_ time: String, _ Distance: String) -> Void)
typealias Completion = () -> Void


class LocationCenter: NSObject, CLLocationManagerDelegate {
    
    let manager = CLLocationManager()
    let geocoder = CLGeocoder()
    var jobCompletion: Completion?
    var country: String = ""
    
    class var isServicesEnabled: Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    
    class var authorizationStatus: CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    
    class var isAlways_OR_WhenInUse: Bool {
        let status = LocationCenter.authorizationStatus
        return (status == CLAuthorizationStatus.authorizedAlways) ||
        (status == CLAuthorizationStatus.authorizedWhenInUse)
    }
    
    class var isDenied: Bool {
        let status = LocationCenter.authorizationStatus
        return status == CLAuthorizationStatus.denied
    }
    
    static let `default`: LocationCenter = {
        let instance: LocationCenter = LocationCenter()
        return instance
    }()
    
    // MARK: -
    
    override init() {
        super.init()
        
        self.manager.delegate = self
        self.manager.activityType = CLActivityType.other
        self.manager.distanceFilter = 10.0
        self.manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.manager.pausesLocationUpdatesAutomatically = false
        // self.manager.allowsBackgroundLocationUpdates = true
    }
    
    
    func requestAuthorization() {
        if LocationCenter.isServicesEnabled && (!LocationCenter.isDenied) {
            self.manager.requestAlwaysAuthorization()
        } else {
            //            if Common.inReview != true {
            //   LocationCenter.allowAlert()
            //            }
        }
    }
    
    func startUpdatingLocation() {
        if LocationCenter.isAlways_OR_WhenInUse {
            self.manager.startUpdatingLocation()
        } else {
            self.requestAuthorization()
            self.jobCompletion = { [weak self] in
                self?.manager.startUpdatingLocation()
            }
        }
    }
    
    func isAllowLocation() {
        if LocationCenter.isAlways_OR_WhenInUse {
            self.manager.startUpdatingLocation()
        }
    }
    
    func stopUpdatingLocation() {
        self.manager.stopUpdatingLocation()
    }
    
    func getCountryCode(for coordinate: CLLocationCoordinate2D, completion: @escaping (PlaceDetails?) -> Void) {
        let urlString = Google.GEOCODE_URL + "latlng=\(coordinate.latitude),\(coordinate.longitude)&key="
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        var request = URLRequest(url: url)
        request.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let results = json["results"] as? [[String: Any]] {
                    
                    var country = ""
                    var isoCountryCode = ""
                    var locality = ""
                    
                    for result in results {
                        if let addressComponents = result["address_components"] as? [[String: Any]] {
                            for component in addressComponents {
                                if let types = component["types"] as? [String] {
                                    if types.contains("country"), country.isEmpty {
                                        country = component["long_name"] as? String ?? ""
                                        isoCountryCode = component["short_name"] as? String ?? ""
                                    } else if types.contains("locality"), locality.isEmpty {
                                        locality = component["long_name"] as? String ?? ""
                                    }
                                }
                            }
                        }
                        
                        // Stop looping if we have all the required information
                        if !country.isEmpty && !isoCountryCode.isEmpty && !locality.isEmpty {
                            break
                        }
                    }
                    
                    if !country.isEmpty || !isoCountryCode.isEmpty || !locality.isEmpty {
                        let placeDetails = PlaceDetails(country: country, isoCountryCode: isoCountryCode, locality: locality)
                        completion(placeDetails)
                    } else {
                        completion(nil)
                    }
                    return
                }
                completion(nil)
            } catch {
                completion(nil)
            }
        }
        task.resume()
    }
    
    func fetchCityAndCountry(location: CLLocation, completion: @escaping (_ city: String?, _ country: String?, _ error: Error?) -> Void) {
        
        getCountryCode(for: location.coordinate) { [weak self] result in
            guard let self = self else { return }
            if let obj = result {
                self.country = obj.country
                completion(obj.locality, obj.country, nil)
            } else {
                let dummyError = NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "location not valid"])
                completion(nil, nil, dummyError)
            }
        }
    }
    
    func getAddressFromLatitudeLongitude(latitude: Double, longitude: Double, completion: @escaping (String, [Double], String) -> Void) {
        let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        if coordinate.isValidCoordinate() {
            let aGMSGeocoder: GMSGeocoder = GMSGeocoder()
            aGMSGeocoder.reverseGeocodeCoordinate(coordinate) { (gmsReverseGeocodeResponse, error) in
                if error == nil {
                    if let gmsAddress: GMSAddress = gmsReverseGeocodeResponse?.firstResult() {
                        let latitude = gmsAddress.coordinate.latitude
                        let longitude = gmsAddress.coordinate.longitude
                        var address: String = ""
                        for line in  gmsAddress.lines ?? [] {
                            address += line + " "
                        }
                        let country = gmsAddress.country
                        completion(address, [latitude, longitude], country ?? "")
                        
                    } else {
                        completion("", [0.0, 0.0], "")
                        
                    }
                } else {
                    completion("", [0.0, 0.0], "")
                }
                
            }
        } else {
            completion("", [0.0, 0.0], "")
        }
    }
    
    func getCityStateCountry(latitude: Double, longitude: Double, completion: @escaping (String, String, String) -> Void) {
        let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        if coordinate.isValidCoordinate() {
            let aGMSGeocoder: GMSGeocoder = GMSGeocoder()
            aGMSGeocoder.reverseGeocodeCoordinate(coordinate) { (gmsReverseGeocodeResponse, error) in
                if error == nil {
                    if let gmsAddress: GMSAddress = gmsReverseGeocodeResponse?.firstResult() {
                        let country = gmsAddress.country ?? ""
                        let state = gmsAddress.administrativeArea ?? ""
                        let city = gmsAddress.locality ?? ""
                        completion(city, state, country)
                    } else {
                        completion("", "", "")
                    }
                } else {
                    completion("", "", "")
                }
            }
        } else {
            completion("", "", "")
        }
    }
    
    
    
    func googlePlacesResult(
        input: String,
        countryCode: String = "SA", // Saudi Arabia by default
        languageCode: String = "ar", // Arabic by default
        completion: @escaping (_ result: [(title: String, subTitle: String, address: String, placeid: String)]) -> Void
    ) {
        guard !input.trimmingCharacters(in: .whitespaces).isEmpty else {
            completion([])
            return
        }

        // Set language for GMSPlaces SDK (by overriding the preferred languages)
        UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()

        // Set up country filter
        let filter = GMSAutocompleteFilter()
        filter.countries = [countryCode]

        // Create request
        let request = GMSAutocompleteRequest(query: input)
        request.filter = filter
        // request.sessionToken = GMSAutocompleteSessionToken() // Optional

        GMSPlacesClient.shared().fetchAutocompleteSuggestions(from: request) { results, error in
            guard error == nil, let results = results else {
                print("Places Error: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }

            let myAddressArray: [(title: String, subTitle: String, address: String, placeid: String)] = results.compactMap { result in
                guard let suggestion = result.placeSuggestion else { return nil }

                let mainTitle = suggestion.attributedPrimaryText.string
                let secondary = suggestion.attributedSecondaryText?.string ?? ""
                let fullAddress = suggestion.attributedFullText.string
                let placeID = suggestion.placeID

                return (title: mainTitle, subTitle: secondary, address: fullAddress, placeid: placeID)
            }

            completion(myAddressArray)
        }
    }

    
    
    //    func googlePlacesResult(input: String, completion: @escaping (_ result: [(title: String, subTitle: String, address: String, placeid: String)]) -> Void) {
    //
    //        guard !input.trimmingCharacters(in: .whitespaces).isEmpty else {
    //            completion([])
    //            return
    //        }
    //
    //        // Set Saudi Arabia as country filter
    //        let filter = GMSAutocompleteFilter()
    //        filter.countries = ["IN"]  // Saudi Arabia
    //
    //        let request = GMSAutocompleteRequest(query: input)
    //        request.filter = filter
    //        // request.sessionToken = GooglePlacesSessionManager.shared.getSessionToken()
    //
    //        GMSPlacesClient.shared().fetchAutocompleteSuggestions(from: request) { results, error in
    //            guard error == nil, let results = results else {
    //                print("Google Places error: \(error?.localizedDescription ?? "Unknown error")")
    //                completion([])
    //                return
    //            }
    //
    //            let myAddressArray: [(title: String, subTitle: String, address: String, placeid: String)] = results.compactMap { result in
    //                guard let suggestion = result.placeSuggestion else { return nil }
    //
    //                let title = suggestion.attributedPrimaryText.string
    //                let subTitle = suggestion.attributedSecondaryText?.string ?? ""
    //                let fullAddress = suggestion.attributedFullText.string
    //                let placeId = suggestion.placeID
    //
    //                return (title: title, subTitle: subTitle, address: fullAddress, placeid: placeId)
    //            }
    //
    //            completion(myAddressArray)
    //        }
    //    }
    
    // MARK: - LocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case CLAuthorizationStatus.notDetermined:
            self.requestAuthorization()
        case CLAuthorizationStatus.restricted:
            break
        case CLAuthorizationStatus.denied:
            break
        case CLAuthorizationStatus.authorizedAlways:
            self.jobCompletion?()
        case CLAuthorizationStatus.authorizedWhenInUse:
            self.jobCompletion?()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let distance = location.distance(from: CLLocation())
        let t1 = location.timestamp.timeIntervalSince1970
        let t2 = CLLocation().timestamp.timeIntervalSince1970
        let time = t1 - t2
        let speed = fabs(distance / time)
        //Common.location = location
        
        if (speed > 166.7) ||
            (location.horizontalAccuracy < 0.0) ||
            (location.horizontalAccuracy > 1000.0) {
            self.stopUpdatingLocation()
            printError("Invalid location speed: \(speed / 1000.0) kilometers/seconds")
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) { [weak self] in
                guard let self = self else { return }
                self.startUpdatingLocation()
            }
            return
        }
        
        if location.coordinate.isValidCoordinate() {
            //  Common.currentCoordinate = location.coordinate
        }
        //        Common.nCd.post(
        //            name: Common.locationUpdateNtfNm,
        //            object: LocationCenter.default,
        //            userInfo: [Common.locationKey: location]
        //        )
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //        Common.nCd.post(
        //            name: Common.locationFailNtfNm,
        //            object: LocationCenter.default,
        //            userInfo: [Common.locationErrorKey: error]
        //        )
    }
    
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        printError("error")
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        printError("paused")
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        printError("resume")
    }
    
    //    func getTimeAndDistance(sourceCoordinate: CLLocationCoordinate2D, destCoordinate: CLLocationCoordinate2D, multipleStops: [StopLocationAddress], tripMultipleStops: [DestinationAddresses], _ completion: @escaping TimeDistanceAPICompletion) {
    //        let time: String = "0"
    //        let distance: String = "0"
    //
    //        if sourceCoordinate.isValidCoordinate() && destCoordinate.isValidCoordinate() {
    //            if sourceCoordinate.isEqual(destCoordinate) && multipleStops.count == 0 {
    //                completion(time, distance)
    //            } else {
    //                let pickup_latitude: String = sourceCoordinate.latitude.toString(places: 7)
    //                let pickup_longitude: String = sourceCoordinate.longitude.toString(places: 7)
    //                let destination_latitude: String = destCoordinate.latitude.toString(places: 7)
    //                let destination_longitude: String = destCoordinate.longitude.toString(places: 7)
    //
    //                var waypoints = ""
    //                for i in 0..<multipleStops.count {
    //                    let add = multipleStops[i]
    //                    if i != 0 {
    //                        waypoints += "|\(add.latitude ?? 0.0),\(add.longitude ?? 0.0)"
    //                    } else {
    //                        waypoints = "\(add.latitude ?? 0.0),\(add.longitude ?? 0.0)"
    //                    }
    //                }
    //
    //                for i in 0..<tripMultipleStops.count {
    //                    let add = tripMultipleStops[i]
    //                    if i != 0 {
    //                        waypoints += "|\(add.location[0]),\(add.location[1] )"
    //                    } else {
    //                        waypoints = "\(add.location[0]),\(add.location[1] )"
    //                    }
    //                }
    //
    //                var strUrl = Google.DIRECTION_URL + "\(pickup_latitude),\(pickup_longitude)&destination=\(destination_latitude),\(destination_longitude)&key=\(UserDefaultsHelper.IosUserGoogleDirectionMatrixKey)" as NSString
    //
    //                if !waypoints.isEmpty {
    //                    strUrl = Google.DIRECTION_URL + "\(pickup_latitude),\(pickup_longitude)&waypoints=\(waypoints)&destination=\(destination_latitude),\(destination_longitude)&key=\(UserDefaultsHelper.IosUserGoogleDirectionMatrixKey)" as NSString
    //
    //                }
    //
    //                if let urlStr = strUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL.init(string: urlStr) {
    //
    //                    var request = URLRequest(url: url)
    //                    request.addValue(Common.bundleId, forHTTPHeaderField: "X-Ios-Bundle-Identifier")
    //
    //                    let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
    //                        guard let data = data, error == nil else {
    //                            completion(time, distance)
    //                            return
    //                        }
    //
    //                        let parseData = self.parseJSON(inputData: data)
    //                        let googleRsponse: GoogleDistanceMatrixResponse = GoogleDistanceMatrixResponse(dictionary: parseData)!
    //                        if (googleRsponse.status?.compare("OK")) == ComparisonResult.orderedSame {
    //
    //                            var t: Int = 0
    //                            var d: Double = 0
    //
    //                            let routes = parseData["routes"] as? [[String: Any]] ?? []
    //
    //                            for route in routes {
    //                                let legs = route["legs"] as? [[String: Any]] ?? []
    //                                for leg in legs {
    //                                    if let distance = leg["distance"] as? [String: Any] {
    //                                        if let value = distance["value"] as? Double {
    //                                            d += value
    //                                        }
    //                                    }
    //                                    if let duration = leg["duration"] as? [String: Any] {
    //                                        if let value = duration["value"] as? Int {
    //                                            t += value
    //                                        }
    //                                    }
    //                                }
    //                            }
    //                            completion(t.toString(), d.toString())
    //                        } else {
    //                            completion(time, distance)
    //                        }
    //                    }
    //                    task.resume()
    //
    //                } else {
    //                    completion(time, distance)
    //                }
    //            }
    //        }
    //    }
    func parseJSON(inputData: Data) -> NSDictionary {
        var dictData: NSDictionary = NSDictionary.init()
        if inputData.count > 0 {
            do {
                if let data = (try JSONSerialization.jsonObject(with: inputData, options: .mutableContainers)) as? NSDictionary {
                    dictData = data
                }
            } catch {
                printError("Response not proper")
            }
        }
        return dictData
    }
}

extension CLLocationCoordinate2D {
    func isValidCoordinate() -> Bool {
        if self.latitude == 0.0 && self.longitude == 0.0 {
            return false
        }
        return CLLocationCoordinate2DIsValid(self)
    }
    
    func isEqual(_ coord: CLLocationCoordinate2D) -> Bool {
        return self.latitude == coord.latitude && self.longitude == coord.longitude
    }
}
