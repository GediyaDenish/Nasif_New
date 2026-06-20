//
//  UserModel.swift
//  Nasif
//
//  Created by Denish Gediya on 15/09/25.
//

import Foundation

// MARK: - UserModel
class UserModel: Codable {
    let code: String
    let mobile: String
    let message: String?
    let isBlocked: Bool
    let isDeleted: Bool
    let avatar: String
    let displayName: String
    let id: String
    let role: String
}

