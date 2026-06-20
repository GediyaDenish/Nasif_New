//
//  AddLocationVC.swift
//  Nasif
//
//  Created by Denish Gediya on 08/07/25.
//

import UIKit
import GoogleMaps
import GooglePlaces

class AddLocationVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var lblTitle: UILabel?
    @IBOutlet weak var btnNext: UIButton?
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var tblLocation: UITableView?
    @IBOutlet weak var vwSearch: UIView?
    @IBOutlet weak var tblSuggestionsHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak var lblCityTitleName: UILabel!
    @IBOutlet weak var txtSearch: UITextField?
    @IBOutlet weak var vwCity: UIView?
    @IBOutlet weak var txtNigboorHood: UITextField!
    @IBOutlet weak var lblNigboorHoodTitle: UILabel!
    @IBOutlet private var vwMenu: [UIView]?
    
    // MARK: - Properties
    private let locationManager = CLLocationManager()
    private var selectedMarker: GMSMarker?
    private var selectedCoordinate: CLLocationCoordinate2D?
    private var selectedPlaceID: String?
    private var selectedCityName: String?
    private var predictions: [GMSAutocompletePrediction] = []
    private var mapTypeIndex = 0
    
    var dictParam: [String: Any] = [:]
    var isFromEdit = false
    var objProperty: Property?
    private var shouldMoveToCurrentLocation = true
    var objCity: CityModel?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureMap()
        configureLocationManager()
        configureTable()
        // configureGestures()
        populateDataIfEditing()
    }
    
    
    // MARK: - Actions
    @IBAction func btnOnClickMode(_ sender: UIButton) {
        mapTypeIndex = (mapTypeIndex + 1) % 4
        mapView.mapType = GMSMapViewType(rawValue: UInt(mapTypeIndex)) ?? .normal
        print("Current map type: \(mapView.mapType.rawValue)")
    }
    
    @IBAction func btnOnClickZoom(_ sender: UIButton) {
        guard let location = locationManager.location else {
            print("📍 User location not available yet.")
            return
        }
        
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        // Move camera to current location
        let camera = GMSCameraPosition.camera(withLatitude: latitude,
                                              longitude: longitude,
                                              zoom: 15.0)
        mapView.animate(to: camera)
        mapView.clear()
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        marker.icon = GMSMarker.markerImage(with: .red) // red default pin
        marker.map = mapView
    }
    
    
    @IBAction func btnOnClickNigboorhood(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "AddList", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "AddNeighborhoodsVC") as? AddNeighborhoodsVC {
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overCurrentContext
            vc.onDismiss = { [weak self] city in
                guard let self else { return }
                self.objCity = city
                
                let coordinate = CLLocationCoordinate2D(latitude: self.objCity?.lat ?? 0.0,
                                                        longitude: self.objCity?.lon ?? 0.0)
                
                
                GMSGeocoder().reverseGeocodeCoordinate(coordinate) { [weak self] response, _ in
                    guard let self = self, let result = response?.firstResult() else { return }
                    // self.txtNigboorHood?.text = self.objCity?.cityEn
                    self.selectedCityName = self.objCity?.cityEn
                    let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 15)
                    mapView.animate(to: camera)
                    locationManager.stopUpdatingLocation()
                }
            }
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnOnClickBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnOnClickNext(_ sender: UIButton) {
        guard let city = txtSearch?.text, !city.isEmpty else {
            return Utility.showNewToast(message: "Please enter the city name.".localized)
        }
        guard let neighborHood = txtNigboorHood?.text, !neighborHood.isEmpty else {
            return Utility.showNewToast(message: "Please enter the neighborHood".localized)
        }
        
        guard let coordinate = selectedCoordinate else {
            return Utility.showNewToast(message: "Please select a valid location on map.".localized)
        }
        
        let storyboard = UIStoryboard(name: "AddList", bundle: nil)
        guard let addMediaVC = storyboard.instantiateViewController(withIdentifier: "AddMediaVC") as? AddMediaVC else { return }
        
        // Prepare parameters
        Utility.addIfValid(&dictParam, key: PARAMS.CITY, value: city)
        Utility.addIfValid(&dictParam, key: PARAMS.NEIGHBORHOOD, value: neighborHood)
        dictParam["location"] = [
            "coordinates": [coordinate.longitude, coordinate.latitude],
            "type": "Point"
        ]
        
        addMediaVC.dictParam = dictParam
        addMediaVC.isFromEdit = isFromEdit
        addMediaVC.objProperty = objProperty
        navigationController?.pushViewController(addMediaVC, animated: true)
    }
    
    //    @objc private func searching(_ sender: UITextField) {
    //        guard let text = sender.text, !text.isEmpty else {
    //            predictions.removeAll()
    //            updateSuggestionsVisibility()
    //            return
    //        }
    //
    //        let filter = GMSAutocompleteFilter()
    //        filter.type = .geocode
    //
    //        GMSPlacesClient.shared().findAutocompletePredictions(fromQuery: text, filter: filter, sessionToken: nil) { [weak self] results, error in
    //            guard let self = self else { return }
    //            if let error = error {
    //                print("Autocomplete error: \(error.localizedDescription)")
    //                return
    //            }
    //
    //            self.predictions = results ?? []
    //            DispatchQueue.main.async { self.updateSuggestionsVisibility() }
    //        }
    //    }
    
    //    @objc private func handleTapOutside() {
    //        view.endEditing(true)
    //        predictions.removeAll()
    //        updateSuggestionsVisibility()
    //    }
}

// MARK: - Private Helpers
private extension AddLocationVC {
    
    func configureUI() {
        vwMenu?.forEach {
            $0.layer.cornerRadius = 22.5
            $0.layer.masksToBounds = true
        }
        lblTitle?.font = FontHelper.font(size: 20.0, type: .Regular)
        btnNext?.titleLabel?.font = FontHelper.font(size: 16.0, type: .Regular)
        btnNext?.setupNewButton(borderColor: .clear, andCornerRadious: 8.0)
        
        mapView.layer.cornerRadius = 5.0
        mapView.clipsToBounds = true
        
        //  txtSearch?.addTarget(self, action: #selector(searching(_:)), for: .editingChanged)
        vwSearch?.setRound(withBorderColor: .themeBorderColor, andCornerRadious: 8.0, borderWidth: 1.0)
        //  vwSearch?.isHidden = true
        vwCity?.setRound(withBorderColor: .themeBorderColor, andCornerRadious: 8.0, borderWidth: 1.0)
        self.txtSearch?.returnKeyType = .done
        self.txtSearch?.delegate = self
        
        self.txtNigboorHood?.returnKeyType = .done
        self.txtNigboorHood?.delegate = self
        
        self.setupLocalized()
    }
    
    func setupLocalized() {
        self.lblTitle?.text = "Location".localized
        self.lblCityTitleName?.text = "City".localized
        self.lblNigboorHoodTitle?.text = "NeighborHood".localized
        self.btnNext?.setTitle("Next".localized, for: .normal)
    }
    
    func configureMap() {
        mapTypeIndex = Int(GMSMapViewType.normal.rawValue)
        mapView.mapType = .normal
        mapView?.isMyLocationEnabled = true
        mapView?.settings.myLocationButton = false
//        mapView.isBuildingsEnabled = true
//        mapView.isTrafficEnabled = true
//        mapView.isIndoorEnabled = true
        mapView?.delegate = self
    }
    
    func configureLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func configureTable() {
        tblLocation?.layer.cornerRadius = 10
        tblLocation?.layer.masksToBounds = true
        //        tblLocation?.delegate = self
        //        tblLocation?.dataSource = self
        tblLocation?.register(UINib(nibName: "SuggestionTVCell", bundle: nil), forCellReuseIdentifier: "SuggestionTVCell")
        tblLocation?.tableFooterView = UIView()
        tblLocation?.keyboardDismissMode = .onDrag
        tblLocation?.isHidden = true
    }
    
    //    func configureGestures() {
    //        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutside))
    //        tapGesture.delegate = self
    //        view.addGestureRecognizer(tapGesture)
    //    }
    
    func populateDataIfEditing() {
        guard isFromEdit, let data = objProperty,
              data.location.coordinates.count >= 2,
              let city = data.city, !city.isEmpty else { return }
        
        let coordinate = CLLocationCoordinate2D(latitude: data.location.coordinates[1],
                                                longitude: data.location.coordinates[0])
        selectedCoordinate = coordinate
        selectedCityName = city
        txtSearch?.text = self.objProperty?.city
        txtNigboorHood?.text = self.objProperty?.neighbourhood
        dropMarker(at: coordinate, title: city)
        mapView.animate(to: GMSCameraPosition.camera(withTarget: coordinate, zoom: 14))
        shouldMoveToCurrentLocation = false
    }
    
    //    func updateSuggestionsVisibility() {
    //        let shouldShow = !predictions.isEmpty
    //        tblSuggestionsHeightConstraint?.constant = shouldShow ? min(CGFloat(predictions.count) * 44, 220) : 0
    //
    //        UIView.animate(withDuration: 0.25) {
    //            self.tblLocation?.isHidden = !shouldShow
    //            self.view.layoutIfNeeded()
    //        } completion: { _ in
    //            self.tblLocation?.reloadData()
    //        }
    //    }
    
    func dropMarker(at coordinate: CLLocationCoordinate2D, title: String? = nil) {
        mapView.clear()
        let marker = GMSMarker(position: coordinate)
        marker.title = title
        marker.map = mapView
        selectedMarker = marker
    }
    
    func updateSelectedPlace(_ place: GMSPlace) {
        selectedCoordinate = place.coordinate
        selectedPlaceID = place.placeID
        selectedCityName = place.addressComponents?.first(where: { $0.types.contains("locality") })?.name ?? place.name
        //        txtSearch?.text = selectedCityName
        //        txtNigboorHood?.text = selectedCityName
        
        //        predictions.removeAll()
        //        updateSuggestionsVisibility()
        
        dropMarker(at: place.coordinate, title: selectedCityName)
        mapView.animate(to: GMSCameraPosition.camera(withTarget: place.coordinate, zoom: 14))
    }
}

// MARK: - CLLocationManagerDelegate
extension AddLocationVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard shouldMoveToCurrentLocation, let currentLocation = locations.first else { return }
        let camera = GMSCameraPosition.camera(withTarget: currentLocation.coordinate, zoom: 15)
        mapView.animate(to: camera)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Error: \(error.localizedDescription)")
    }
}

// MARK: - GMSMapViewDelegate
extension AddLocationVC: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        self.view.endEditing(true)
        dropMarker(at: coordinate)
        selectedCoordinate = coordinate
        
        GMSGeocoder().reverseGeocodeCoordinate(coordinate) { [weak self] response, _ in
            guard let self = self, let result = response?.firstResult() else { return }
            self.selectedCityName = result.locality ?? result.administrativeArea ?? result.country
            // self.txtNigboorHood?.text = self.objCity?.cityEn
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
//extension AddLocationVC: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { predictions.count }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestionTVCell", for: indexPath) as? SuggestionTVCell else {
//            return UITableViewCell()
//        }
//        cell.lblSuggestion?.attributedText = predictions[indexPath.row].attributedPrimaryText
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard indexPath.row < predictions.count else { return }
//        let prediction = predictions[indexPath.row]
//
//        tableView.isUserInteractionEnabled = false
//        GMSPlacesClient.shared().fetchPlace(fromPlaceID: prediction.placeID,
//                                            placeFields: [.coordinate, .name, .placeID, .addressComponents],
//                                            sessionToken: nil) { [weak self] place, error in
//            DispatchQueue.main.async {
//                tableView.isUserInteractionEnabled = true
//                if let place = place {
//                    self?.updateSelectedPlace(place)
//                } else {
//                    print("❌ Place fetch failed: \(error?.localizedDescription ?? "unknown error")")
//                    Utility.showToast(message: "Failed to fetch location details.".localized)
//                }
//            }
//        }
//    }
//}

// MARK: - UIGestureRecognizerDelegate
extension AddLocationVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let touchedView = touch.view else { return true }
        return !touchedView.isDescendant(of: tblLocation ?? UITableView())
    }
}

extension AddLocationVC : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // ✅ Dismiss keyboard
        return true
    }
}
