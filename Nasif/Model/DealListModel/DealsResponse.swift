//
//  DealsResponse.swift
//  Nasif
//
//  Created by Denish Gediya on 20/08/25.
//

import Foundation

// MARK: - Root Response
class DealsResponse: Codable {
    let content: [Deal]?
    let totalElements: Int?
    let size: Int?
    let totalPages: Int?
    let page: Int?
    let pagingCounter: Int?
    let hasPrevPage: Bool
    let hasNextPage: Bool
    let prevPage: Int?
    let nextPage: Int?
}

// MARK: - Deal
class Deal: Codable {
    let dealNo: Int?
    let property: PropertyDeal?
    let user: UserDetail?
    let buyer: UserDetail?
    let status: String?
    let name: String?
    let lastMessage: LastMessage?
    var subStatus: Int?
    let id: String?
    let isExit: Bool?
    let unReadMsg: Int?
    let isArchived: Bool?
}

// MARK: - Property
class PropertyDeal: Codable {
    let id: String?
    let city: String?
    let status: String?
    let neighbourhood: String?
    let availableFor: String?
    let type: String?
    let price: Int?
    let area: Int?
    let coverImage: String?
    let totalBedrooms: Int?
    let totalBathrooms: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case city, neighbourhood, availableFor, type, price, area, coverImage, status, totalBedrooms, totalBathrooms
    }
}

// MARK: - LastMessage
class LastMessage: Codable {
    let id: String?
    let sender: String?
    let type: String?
    let text: String?
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case sender, type, text, createdAt
    }
}
