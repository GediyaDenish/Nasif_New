//
//  SignupResponse.swift
//  Nasif
//
//  Created by Denish Gediya on 03/07/25.
//

import Foundation

// MARK: - AuthResponse
class SignupResponse: Codable {
    let userId: String
    let accessToken: String
    let type: String
    let mobile: String
    let code: String
    let topic: String
    let message: String?
    let isNew: Bool
    
    enum CodingKeys: String, CodingKey {
        case userId
        case accessToken
        case type
        case mobile
        case code
        case topic
        case message
        case isNew
    }
}

