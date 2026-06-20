//
//  ChatMessagesResponse.swift
//  Nasif
//
//  Created by Denish Gediya on 07/10/25.
//

import Foundation

// MARK: - Root Response
struct ChatMessagesResponse: Codable {
    let content: [ChatGroupMessage]
    let totalPages, size: Int?
    let hasNextPage, hasPrevPage: Bool
    let pagingCounter, totalElements, page: Int?
    
    enum CodingKeys: String, CodingKey {
        case content, totalPages, size, hasNextPage, pagingCounter, hasPrevPage, totalElements, page
    }
}

// MARK: - Chat Content
struct ChatGroupMessage: Codable {
    let chat: String?
    let createdAt: String?
    let sender: ChatSender?
    let property: ChatProperty?
    let id: String?
    let type: String?
    let text: String?
    let file: String?
    let fileType: String?
    let fileName: String?
}

struct ChatProperty: Codable {
    let id: String?
    let city: String?
    let neighbourhood: String?
    let availableFor: String?
    let type: String?
    let price: Double?
    let area: Double?
    let coverImage: String?
    let status: String?
    let eastFacing: Int?
    let totalBathrooms: Int?
    let totalLivingrooms: Int?
    let totalBedrooms: Int?
    let westFacing: Int?
    let southFacing: Int?
    let northFacing: Int?
    let streets: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case city, availableFor, type, price, area, coverImage, neighbourhood, status, eastFacing, totalBathrooms, totalLivingrooms,totalBedrooms, westFacing,southFacing,northFacing,streets
    }
}

struct MessageSection {
    let date: String
    var messages: [ChatGroupMessage]
}

// MARK: - Last Message
struct LastGroupMessage: Codable {
    let fileType: String?
    let id: String?
    let sender: String?
    let type: String?
    let file: String?
    let createdAt: String?
    let text: String?
    let fileName: String?
    
    enum CodingKeys: String, CodingKey {
        case fileType
        case id = "_id"
        case sender, type, file, createdAt, text, fileName
    }
}

// MARK: - ChatSender
class ChatSender: Codable {
    let id: String?
    let mobile: String?
    let displayName: String?
    let avatar: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case mobile, displayName, avatar
    }
}


