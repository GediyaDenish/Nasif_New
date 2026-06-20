//
//  MyAppTheme.swift
//  Nasif
//
//  Created by Denish Gediya on 21/06/25.
//

import UIKit

extension UIColor {
    static let themeBorderColor: UIColor = UIColor(red: 217 / 255, green: 217 / 255, blue: 217 / 255, alpha: 1.0)
    static let themePrimaryColor: UIColor = UIColor(red: 50 / 255, green: 173 / 255, blue: 230 / 255, alpha: 1.0)
    static let themePrimaryColor50: UIColor = UIColor(red: 50 / 255, green: 173 / 255, blue: 230 / 255, alpha: 0.5)
    static let themeBorderColor808080: UIColor = UIColor(red: 128 / 255, green: 128 / 255, blue: 128 / 255, alpha: 5.0)
    static let themeBorderColor808080185: UIColor = UIColor(red: 185 / 255, green: 185 / 255, blue: 185 / 255, alpha: 5.0)
    static let themeColorD9D9D9: UIColor = UIColor(red: 217 / 255, green: 217 / 255, blue: 217 / 255, alpha: 1.0)
    static let themeErrorTextColor: UIColor = UIColor(red: 220 / 255, green: 74 / 255, blue: 48 / 255, alpha: 1.0)
    static let themeF1F1F1: UIColor = UIColor(red: 241 / 255, green: 241 / 255, blue: 241 / 255, alpha: 1.0)
    static let theme32ADE6: UIColor = UIColor(red: 50 / 255, green: 173 / 255, blue: 230 / 255, alpha: 0.5)
    static let theme287346: UIColor = UIColor(red: 40 / 255, green: 115 / 255, blue: 70 / 255, alpha: 0.5)
    static let themeD9D9D9: UIColor = UIColor(red: 217 / 255, green: 217 / 255, blue: 217 / 255, alpha: 0.7)
    static let themeSelect: UIColor = UIColor(red: 153 / 255, green: 153 / 255, blue: 153 / 255, alpha: 0.5)
    static let theme999999: UIColor = UIColor(red: 153 / 255, green: 153 / 255, blue: 153 / 255, alpha: 1.0)
    static let themeButtonBackgroundColor: UIColor = UIColor(red: 63 / 255, green: 192 / 255, blue: 81 / 255, alpha: 1.0)
    static let themeBackgroundRedColor: UIColor = UIColor(red: 197 / 255, green: 0 / 255, blue: 0 / 255, alpha: 1.0)
    static let themeBackgroundBlueColor: UIColor = UIColor(red: 122 / 255, green: 18 / 255, blue: 233 / 255, alpha: 1.0)
    static let themeBackgroundGreenColor: UIColor = UIColor(red: 40 / 255, green: 115 / 255, blue: 70 / 255, alpha: 1.0)
    static let themePurpor: UIColor = UIColor(red: 125 / 255, green: 0 / 255, blue: 226 / 255, alpha: 1.0)
    static let themeBackgroundGreenColor50: UIColor = UIColor(red: 40 / 255, green: 115 / 255, blue: 70 / 255, alpha: 0.5)
    static let themeShadowColor: UIColor = UIColor(red: 160 / 255.0, green: 160 / 255.0, blue: 160 / 255.0, alpha: 1.0)
    static let themeOverlayColor: UIColor = UIColor(red: 80 / 255.0, green: 80 / 255.0, blue: 80 / 255.0, alpha: 0.8)
    static let themeTextColor: UIColor = UIColor(red: 31 / 255.0, green: 31 / 255.0, blue: 31 / 255.0, alpha: 0.8)
    static let themeImageColor: UIColor = UIColor(red: 33 / 255, green: 166 / 255, blue: 53 / 255, alpha: 1.0)
    static let themeButtonBackgroundColor7D7D7D: UIColor = UIColor(red: 237 / 255, green: 237 / 255, blue: 237 / 255, alpha: 1.0)
    static let themeButtonTitleColor: UIColor = UIColor(red: 71 / 255, green: 71 / 255, blue: 71 / 255, alpha: 1.0)
    static let themeButtonBlackColor: UIColor = UIColor(red: 0 / 255, green: 0 / 255, blue: 0 / 255, alpha: 0.1)
    static let themeButton636363: UIColor = UIColor(red: 99 / 255, green: 99 / 255, blue: 99 / 255, alpha: 1.0)
    
    static func color(for name: String?) -> UIColor {
        guard let name = name, !name.isEmpty else {
            return .label
        }
        
        // Convert name into a simple numeric hash
        var total: Int = 0
        for scalar in name.unicodeScalars {
            total += Int(UInt32(scalar))
        }
        
        // Generate hue based on hash (gives unique tone per name)
        let hue = CGFloat((total % 256)) / 255.0
        let saturation: CGFloat = 0.65   // vividness of color
        let brightness: CGFloat = 0.9    // how bright the color looks
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }
}

struct FontSize {
    static let regular: CGFloat = 14
}

enum FontType {
    case Regular
}

enum FontHelper {
    static func font(size: CGFloat = FontSize.regular, type: FontType) -> UIFont {
        switch type {
        case .Regular:
            return UIFont(name: "SFArabic-Regular", size: size)!
        }
    }
}



extension Notification.Name {
    static let didChangeCustomLocation = Notification.Name("didChangeCustomLocation")
}
