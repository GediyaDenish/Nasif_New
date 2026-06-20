//
//  CityModel.swift
//  Nasif
//
//  Created by Denish Gediya on 20/09/25.
//

import Foundation

// MARK: - City Model
struct CityModel: Codable {
    let cityEn: String
    let city: String
    let lat: Double
    let lon: Double

    enum CodingKeys: String, CodingKey {
        case cityEn = "city_en"
        case city
        case lat
        case lon
    }
}


