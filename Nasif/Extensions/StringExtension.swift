//
//  StringExtension.swift
//  Nasif
//
//  Created by Denish Gediya on 03/07/25.
//

import Foundation

extension String {
    
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    struct NumberFormat {
        static let instance = NumberFormatter()
    }
    
    func urlEncoded() -> String? {
        addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)?
            .replacingOccurrences(of: "&", with: "%26")
    }

    /// Always use Arabic bundle
    private var arabicBundle: Bundle {
        let path = Bundle.main.path(forResource: "ar", ofType: "lproj")!
        return Bundle(path: path)!
    }
    
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: arabicBundle, value: "", comment: "")
    }

    var localizedCapitalized: String {
        localized.capitalized
    }

    var localizedUppercase: String {
        localized.uppercased()
    }
}
