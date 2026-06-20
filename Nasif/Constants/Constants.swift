//
//  Constants.swift
//  Nasif
//
//  Created by Denish Gediya on 03/07/25.
//

import Foundation
import UIKit
import FirebaseMessaging

// MARK: - Abbreviation
let APPDELEGATE = AppDelegate.SharedApplication()

struct WebService {
    static var firebaseMessaging:Messaging?
    struct APIConfig {
        #if DEBUG
        static let BASE_URL = "https://dev.appnasif.com"
        #else
        static let BASE_URL = "https://live.appnasif.com"
        #endif

        static let API = BASE_URL + "/api/v1/"
    }
    
    static let SIGNIN = "auth/signin"
    static let SIGNUP = "auth/signup"
    static let PROFILE = "users/me"
    static let DELETE_ACCOUNT = "users/delete/me/"
    static let AUTH_VERIFY = "auth/verify"
    static let PROPERTY = "properties/"
    static let CHATS = "chats/"
    static let NEIGHBORHOODS = "commons/neighborhoods/"
    static let DEALS = "deals/"
    static let ARCHIVED = "archived/"
    static let CONTACTS = "commons/contacts/"
    
    static let GET_USER_SETTING_DETAIL = "get_user_setting_detail"
    static let SEND_OTP = "send-otp"
    static let VERIFY_OTP = "verify-otp"
    static let LOGIN_VERIFY_OTP = "login-verify-otp"
    static let LOGIN_SEND_OTP = "login-send-otp"
    static let PROFILE_UPDATE = "profile/update"
    static let PROFILE_DELETE = "profile/delete"
    static let LOGOUT = "logout"
    static let PROPERTY_ADD = "property/add"
    static let PROPERTY_UPDATE = "property/update"
    static let PROPERTY_DELETE = "property/delete"
    
    static let PROPERTY_IMAGE_DELETE = "property/image-delete"
    static let DEAL_LIST = "deal-list"
    static let CHECK_NUMBERS = "check-numbers"
    static let PROPERTY_SHARE_LIST = "property/share-list"
    static let DEAL_CHAT_MESSAGE = "deal-chat-message"
    static let DEAL_CHAT = "deal-chat"
    static let DEAL_CREATE = "deal-create"
    static let DEAL_UPDATE = "deal-update"
    static let PROPERTY_SHARE = "property/share"
}

public func getFilter() -> String {
    var components: [String] = []
    
    if let minPrice = ListingFilterKeys.minPrice {
        components.append("minPrice=\(minPrice)")
    }
    if let maxPrice = ListingFilterKeys.maxPrice {
        components.append("maxPrice=\(maxPrice)")
    }
    if let minArea = ListingFilterKeys.minArea {
        components.append("minArea=\(minArea)")
    }
    if let maxArea = ListingFilterKeys.maxArea {
        components.append("maxArea=\(maxArea)")
    }
    if let minAge = ListingFilterKeys.minAge {
        components.append("minAge=\(minAge)")
    }
    if let maxAge = ListingFilterKeys.maxAge {
        components.append("maxAge=\(maxAge)")
    }
    if let totalFloors = ListingFilterKeys.totalFloors {
        components.append("totalFloors=\(totalFloors)")
    }
    if let floorNumber = ListingFilterKeys.floorNumber {
        components.append("floorNumber=\(floorNumber)")
    }
    if let totalBedrooms = ListingFilterKeys.totalBedrooms {
        components.append("totalBedrooms=\(totalBedrooms)")
    }
    if let totalBathrooms = ListingFilterKeys.totalBathrooms {
        components.append("totalBathrooms=\(totalBathrooms)")
    }
    if let totalLivingrooms = ListingFilterKeys.totalLivingrooms {
        components.append("totalLivingrooms=\(totalLivingrooms)")
    }
    if let availableParking = ListingFilterKeys.availableParking {
        components.append("availableParking=\(availableParking)")
    }
    
    if let city = ListingFilterKeys.city {
        components.append("city=\(city.urlEncoded() ?? "")")
    }
    if let search = ListingFilterKeys.search {
        components.append("search=\(search.urlEncoded() ?? "")")
    }
    if let listingNo = ListingFilterKeys.listingNo {
        components.append("listingNo=\(listingNo.urlEncoded() ?? "")")
    }
    if let type = ListingFilterKeys.type {
        components.append("type=\(type.urlEncoded() ?? "")")
    }
    if let facing = ListingFilterKeys.facing {
        components.append("facing=\(facing.urlEncoded() ?? "")")
    }
    if let streets = ListingFilterKeys.streets {
        components.append("streets=\(streets.urlEncoded() ?? "")")
    }
    if let vilaType = ListingFilterKeys.vilaType {
        components.append("vilaType=\(vilaType.urlEncoded() ?? "")")
    }
    if let useFor = ListingFilterKeys.useFor {
        components.append("useFor=\(useFor.urlEncoded() ?? "")")
    }
    if let services = ListingFilterKeys.services {
        components.append("services=\(services.urlEncoded() ?? "")")
    }
    if let availableFor = ListingFilterKeys.availableFor {
        components.append("availableFor=\(availableFor.urlEncoded() ?? "")")
    }
    if let extraFeatures = ListingFilterKeys.extraFeatures {
        components.append("extraFeatures=\(extraFeatures.urlEncoded() ?? "")")
    }
    if let status = ListingFilterKeys.status {
        components.append("status=\(status.urlEncoded() ?? "")")
    }
//    if let lng = ListingFilterKeys.lng {
//        components.append("lng=\(lng)")
//    }
//    if let lat = ListingFilterKeys.lat {
//        components.append("lat=\(lat)")
//    }
    return components.isEmpty ? "" : "&" + components.joined(separator: "&")
}


func setInterval(date: Date, datePicker: UIDatePicker) -> Date {
    let calendar = Calendar.current
    let currentDate = date
    
    // Extract hour and minute components from the current date
    var currentHour = calendar.component(.hour, from: currentDate)
    var currentMinute = calendar.component(.minute, from: currentDate)
    
    // Round the minute to the next 15-minute interval
    if currentMinute > 45 {
        currentMinute = 0
        currentHour = (currentHour + 1) % 24 // Increase the hour and handle 24-hour format
    } else if currentMinute > 30 {
        currentMinute = 45
    } else if currentMinute > 15 {
        currentMinute = 30
    } else if currentMinute > 0 {
        currentMinute = 15
    } else {
        currentMinute = 0
    }
    
    // Create a DateComponents instance to set the min date
    var components = calendar.dateComponents([.year, .month, .day, .hour], from: currentDate)
    components.hour = currentHour
    components.minute = currentMinute
    components.second = 0
    
    // Generate the minimum date
    let minDate = calendar.date(from: components) ?? currentDate
    
    // Set the UIDatePicker properties
    //    datePicker.minimumDate = minDate
    //    datePicker.date = minDate
    datePicker.minuteInterval = 15
    return minDate
}

struct DateFormat {
    static let TIME_FORMAT_AM_PM = "hh:mm a"
    static let WEB = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    static let DATE_TIME_FORMAT = "dd MMMM yyyy, HH:mm"
    static let HISTORY_TIME_FORMAT = "hh:mm a"
    static let DATE_FORMAT = "yyyy-MM-dd"
    static let DATE_FORMAT_MONTH = "MMMM yyyy"
    static let DATE_MM_DD_YYYY = "MM/dd/yyyy"
    static let TIME_FORMAT_HH_MM = "HH:mm"
    static let DATE_TIME_FORMAT_AM_PM = "yyyy-MM-dd hh:mm a"
    static let SCHEDUALE_DATE_FORMATE = "EEEE d MMMM 'at' HH:mm"
    static let MESSAGE_FORMAT = "yyyy-MM-dd, hh:mm a"
    static let DATE_TIME_24 = "yyyy-MM-dd HH:mm:ss"
    
    static let DATE_FOR_RENT = "dd-MM-yy HH:mm"
    static let DATE_MMMM = "MMMM dd,yyyy"
    static let DATE_MMMM_YYYY = "MMMM d, yyyy"
    
}

struct Google {
    static var GEOCODE_URL: String {
        return "https://maps.googleapis.com/" + "maps/api/geocode/json?"
    }
    static var AUTO_COMPLETE_URL: String {
        return "https://maps.googleapis.com/" + "maps/api/place/autocomplete/json?"
    }
    static var TIME_DISTANCE_URL: String {
        return "https://maps.googleapis.com/" + "maps/api/distancematrix/json?origins="
    }
    static var DIRECTION_URL: String {
        return "https://maps.googleapis.com/" + "maps/api/directions/json?origin="
    }
    
    // MARK: Keys
    static var MAP_KEY = "AIzaSyBDMdhd2RszlsxkRSkf3EByTG1ZPIxjOI8"
    //static var CLIENT_ID = "334980166620-3b5eg9qbsslicn6q33c5pbncddp9q7de.apps.googleusercontent.com"
    
}

struct PARAMS {
    static let IMAGE_URL = "picture_data"
    static let MOBILE = "mobile"
    static let USERS = "users"
    static let PROPERTY_ID = "propertyId"
    static let ADMINS = "admins"
    static let MODERATORS = "moderators"
    static let MEMBERS = "members"
    static let CONTACTS = "contact"
    static let BUYER_ID = "buyerId"
    static let OTP = "otp"
    static let NAME = "name"
    static let IMG = "img"
    static let CODE = "code"
    static let AVATAR = "avatar"
    static let DISPLAYNAME = "displayName"
    
    static let AVAILABLE_FOR = "availableFor"
    static let TYPE = "type"
    static let GROUP_NAME = "groupName"
    static let GROUP_DESCRIPTION = "groupDescription"
    static let GROUP_IMAGE = "groupImage"
    static let FILE = "file"
    static let FILE_TYPE = "fileType"
    static let FILE_NAME = "fileName"
    static let TYPENEW = "type"
    static let LATITUDE = "latitude"
    static let DATA = "data"
    static let LONGITUDE = "longitude"
    static let RADIUS = "radius"
    static let PRICE_MAX = "price_max"
    static let PRICE_MIN = "price_min"
    static let PRICE = "price"
    static let AREA = "area"
    static let AGE = "age"
    static let NORTH_FACING = "northFacing"
    static let EAST_FACING = "eastFacing"
    static let WEST_FACING = "westFacing"
    static let SOUTH_FACING = "southFacing"
    static let VILA_TYPE = "vilaType"
    static let LAND_TYPE = "landType"
    static let FLOORS_NUMBER = "floorNumber"
    static let TOTAL_FLOORS = "totalFloors"
    static let TOTAL_BEDROOM = "totalBedrooms"
    static let TOTAL_BATHROOM = "totalBathrooms"
    static let TOTAL_LIVINGROOM = "totalLivingrooms"
    static let AVAILABLE_PARKING = "availableParking"
    static let SERVICES = "services"
    static let EXTRA_FEATURES = "extraFeatures"
    static let CITY = "city"
    static let NEIGHBORHOOD = "neighbourhood"
    static let COORDINATES = "coordinates"
    static let LOCATION = "location"
    static let COVER_IMAGE = "coverImage"
    static let IMAGES = "images"
    static let LET = "let"
    static let LONG = "long"
    static let PLACEID = "placeid"
    static let THUMB_IMAGE = "thumb_image"
    static let EX_IMAGE = "ex_image"
    static let ADVERTISER_ROLE = "advertisersRole"
    static let PLAN_NUMBER = "planNumber"
    static let PLOT_NUMBER = "plotNumber"
    static let FAL_LICENSE_NUMBER = "falLicenseNumber"
    static let ADVERTISEMENT_LICENSE_NUMBER = "licenseNumber"
    static let OWNERS_NAME = "ownerName"
    static let OWNERS_NUMBER = "ownerNumber"
    static let DESCRIPTION = "description"
    static let ID = "id"
    static let P_ID = "p_id"
    static let U_ID = "u_id"
    static let STEP = "step"
    static let STATUS = "status"
    static let RECEIVER_ID = "receiver_id"
    static let MESSAGE = "message"
    static let DEAL_ID = "deal_id"
    static let DELETED = "deleted"
    static let IS_EXIST = "is_exist"
    
    
    static let page = "page"
    static let size = "size"
    static let sort = "sort"
    static let search = "search"
    static let lng = "lng"
    static let lat = "lat"
    static let distance = "distance"
    static let listingNo = "listingNo"
    static let type = "type"
    static let minPrice = "minPrice"
    static let maxPrice = "maxPrice"
    static let minArea = "minArea"
    static let maxArea = "maxArea"
    static let facing = "facing"
    static let streets = "streets"
    static let minAge = "minAge"
    static let maxAge = "maxAge"
    static let vilaType = "vilaType"
    static let useFor = "useFor"
    static let totalFloors = "totalFloors"
    static let floorNumber = "floorNumber"
    static let totalBedrooms = "totalBedrooms"
    static let totalBathrooms = "totalBathrooms"
    static let totalLivingrooms = "totalLivingrooms"
    static let availableParking = "availableParking"
    static let services = "services"
    static let availableFor = "availableFor"
    static let extraFeatures = "extraFeatures"
    static let status = "status"
    
}

class ListingFilterKeys {
    // MARK: - Int
    static var minPrice: Int? = nil
    static var maxPrice: Int? = nil
    static var minArea: Int? = nil
    static var maxArea: Int? = nil
    static var minAge: Int? = nil
    static var maxAge: Int? = nil
    static var totalFloors: Int? = nil
    static var floorNumber: Int? = nil
    static var totalBedrooms: Int? = nil
    static var totalBathrooms: Int? = nil
    static var totalLivingrooms: Int? = nil
    static var availableParking: Int? = nil
        
    // MARK: - String
    static var city: String? = nil
    static var neighbourhood: String? = nil
    static var search: String? = nil
    static var listingNo: String? = nil
    static var type: String? = nil
    static var facing: String? = nil
    static var streets: String? = nil
    static var vilaType: String? = nil
    static var useFor: String? = nil
    static var services: String? = nil
    static var availableFor: String? = nil
    static var extraFeatures: String? = nil
    static var status: String? = nil
    static var lng: Double? = nil
    static var lat: Double? = nil
}

public func resetFilter() {
    ListingFilterKeys.availableFor = nil
    ListingFilterKeys.facing = nil
    ListingFilterKeys.vilaType = nil
    ListingFilterKeys.status = nil
    ListingFilterKeys.useFor = nil
    ListingFilterKeys.extraFeatures = nil
    ListingFilterKeys.floorNumber = nil
    ListingFilterKeys.totalBedrooms = nil
    ListingFilterKeys.totalBathrooms = nil
    ListingFilterKeys.totalLivingrooms = nil
    ListingFilterKeys.availableParking = nil
    ListingFilterKeys.totalFloors = nil
    ListingFilterKeys.city = nil
    ListingFilterKeys.neighbourhood = nil
    ListingFilterKeys.search = nil
    ListingFilterKeys.minAge = nil
    ListingFilterKeys.maxAge = nil
    ListingFilterKeys.minArea = nil
    ListingFilterKeys.maxArea = nil
    ListingFilterKeys.minPrice = nil
    ListingFilterKeys.maxPrice = nil
    ListingFilterKeys.lng = nil
    ListingFilterKeys.lat = nil
}
