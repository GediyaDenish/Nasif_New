//
//  PropertyResponse.swift
//  Nasif
//
//  Created by Denish Gediya on 15/09/25.
//

import Foundation

// MARK: - Root Response
struct PropertyResponse: Codable {
    let content: [Property]
    let totalElements: Int
    let size: Int
    let totalPages: Int
    let page: Int
    let pagingCounter: Int
    let hasPrevPage: Bool
    let hasNextPage: Bool
    let prevPage: Int?
    let nextPage: Int?
}

// MARK: - Root Model
struct Property: Codable {
    let location: Location
    let listingNo: Int?
    let streets: Int?
    let user: String?
    let city: String?
    let neighbourhood: String?
    let isDeleted: Bool?
    let isHidden: Bool?
    let availableFor: String?
    let status: String?
    let type: String?
    let comission: String?
    let reservation: String?
    let visits: String?
    let price: Int
    let area: Int
    let age: Int?
    let northFacing: Int?
    let comissionPrice: Int?
    let eastFacing: Int?
    let westFacing: Int?
    let southFacing: Int?
    let vilaType: String?
    let landType: String?
    let useFor: [String]?
    let floorNumber: Int?
    let totalFloors: Int?
    let totalBedrooms: Int?
    let totalBathrooms: Int?
    let totalLivingrooms: Int?
    let availableParking: Int?
    let services: [String]?
    let extraFeatures: [String]?
    let coverImage: String?
    let images: [String]?
    let medias: [String]?
    let id: String?
    let advertisersRole: String?
    let planNumber: String?
    let plotNumber: String?
    let falLicenseNumber: String?
    let licenseNumber: String?
    let ownerNumber: String?
    let ownerName: String?
    let name: String?
    let description: String?
    let isProject: Bool?
    let userDetail: UserDetail?
}

// MARK: - Location
struct Location: Codable {
    let coordinates: [Double]
    let type: String?
}

// MARK: - User Detail
struct UserDetail: Codable {
    let id: String?
    let avatar: String?
    let displayName: String?
    let mobile: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case avatar
        case displayName
        case mobile
    }
}
