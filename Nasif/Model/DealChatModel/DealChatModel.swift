//
//  DealChatModel.swift
//  Nasif
//
//  Created by Denish Gediya on 18/09/25.
//

import Foundation

// MARK: - Root Model
struct DealChatModel: Codable {
    let content: [DealContent]
    let totalPages, size: Int
    let hasNextPage, hasPrevPage: Bool
    let pagingCounter, totalElements: Int
    var page: Int
    
    enum CodingKeys: String, CodingKey {
        case  content, totalPages, size, hasNextPage, hasPrevPage, pagingCounter, totalElements, page
    }
}

// MARK: - Message Model
struct DealContent: Codable {
    let deal: String
    let createdAt: String
    let sender: Sender
    let id: String
    let type: String
    let text: String?
    let fileName: String?
    let file: String?
    let fileType: String?
    
    enum MessageType: String, Codable {
        case title = "Title"
        case text = "Text"
        case image = "Image"
    }
}

// MARK: - Sender Model
struct Sender: Codable {
    let id: String
    let mobile: String
    let displayName: String
    let avatar: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case mobile, displayName, avatar
    }
}
