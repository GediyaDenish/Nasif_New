//
//  ChatModel.swift
//  Nasif
//
//  Created by Denish Gediya on 07/10/25.
//


import Foundation

// MARK: - Response Model
struct ChatModel: Codable {
    let content: [ChatMessage]
    let totalElements, size, totalPages, page: Int
    let pagingCounter: Int
    let hasPrevPage, hasNextPage: Bool
}

// MARK: - GroupChat
struct ChatMessage: Codable {
    let id: String?
    let status: Bool?
    let member: [GroupUser]?
    let unRead: Int?
    let totalPeoples: Int?
    let isArchived: Bool?
    let isAdmin: Bool?
    let isModerator: Bool?
    let isMember: Bool?
    let isBlock: Bool?
    var isGroup: Bool?
    let admin: [GroupUser]?
    let groupName: String?
    let groupDescription: String?
    let moderator: [GroupUser]?
    let groupImage: String?
    let lastMessage: LastChatMessage?
    let oposition: ChatSender?
}

// MARK: - LastMessage
struct LastChatMessage: Codable {
    let _id: String?
    let sender: String?
    let type: String?
    let text: String?
    let createdAt: String?
}

// MARK: - GroupUser
struct GroupUser: Codable {
    var id: String?
    var mobile: String?
    var avatar: String?
    var displayName: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case mobile, avatar, displayName
    }
}

