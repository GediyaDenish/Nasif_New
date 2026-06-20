//
//  MessageModel.swift
//  Nasif
//
//  Created by Denish Gediya on 18/09/25.
//

import Foundation

struct MessageModel: Codable {
    let type: String
    var text: String?
    var property: String?
    var file: String?
    var fileType: String?
    var fileName: String?
}
