//
//  UserContact.swift
//  Nasif
//
//  Created by Denish Gediya on 23/08/25.
//

import Foundation

struct UserContact: Codable {
    var mobile: String?
    var name: String?
    let normalizedMobile: String?
    var id: String?
    var avatar: String?
    var displayName: String?
}

// MARK: - Section Model
struct Section {
    let title: String
    var contacts: [UserContact]
}
