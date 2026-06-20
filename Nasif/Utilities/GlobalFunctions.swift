//
//  GlobalFunctions.swift
//  Nasif
//
//  Created by Denish Gediya on 01/07/25.
//

import AVFoundation
import UIKit
import PDFKit

//MARK: - UIApplication Extension
extension UIApplication {
    
    class func topViewController(base: UIViewController? = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
    
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
    
}

func formatAPIDateToTime(_ dateString: String) -> String {
    let inputFormatter = ISO8601DateFormatter()
    inputFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    
    guard let date = inputFormatter.date(from: dateString) else {
        return dateString
    }
    
    let outputFormatter = DateFormatter()
    outputFormatter.calendar = Calendar(identifier: .gregorian) // ✅ Force Gregorian calendar
    outputFormatter.locale = Locale(identifier: "en_US_POSIX")  // Stable time format handling
    outputFormatter.timeZone = TimeZone(identifier: "Asia/Kolkata")
    outputFormatter.dateFormat = "hh:mm a"  // Example: 05:46 PM
    
    return outputFormatter.string(from: date)
}

func formatNewAPIDateToTime(_ dateString: String) -> String {
    let inputFormatter = ISO8601DateFormatter()
    inputFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    
    // Convert input string to Date
    guard let date = inputFormatter.date(from: dateString) else {
        return dateString
    }
    
    // Output Formatter
    let outputFormatter = DateFormatter()
    outputFormatter.calendar = Calendar(identifier: .gregorian) // ✅ Force Gregorian Calendar
    outputFormatter.locale = Locale(identifier: "en_US_POSIX")  // Stable date formatting
    outputFormatter.timeZone = TimeZone(identifier: "Asia/Kolkata")
    outputFormatter.dateFormat = "dd/MM/yyyy"
    
    return outputFormatter.string(from: date)
}


func formatDateString(_ isoDate: String, format: String = "EEEE، d MMMM", locale: Locale = Locale(identifier: "en_US")) -> String {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    
    guard let date = formatter.date(from: isoDate) else { return "" }
    
    let displayFormatter = DateFormatter()
    displayFormatter.dateFormat = format
    displayFormatter.locale = locale  // 👈 For language/region
    
    return displayFormatter.string(from: date)
}

func formatPriceNew(_ amountString: String?) -> String {
    guard var amountString = amountString else { return "" }

    // Remove non-digits
    amountString = amountString.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)

    guard let amount = Double(amountString) else { return "" }

    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.locale = Locale(identifier: "en_SA")  // Saudi format but English digits
    formatter.maximumFractionDigits = 0

    return formatter.string(from: NSNumber(value: amount)) ?? amountString
}

func logout(from controller: UIViewController,message: String, completion: @escaping (Bool) -> Void) {
    let alert = UIAlertController(
        title: "",
        message: message,
        preferredStyle: .alert
    )
    
    alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel) { _ in
        completion(false)
    })
    
    alert.addAction(UIAlertAction(title: "Logout".localized, style: .default) { _ in
        completion(true)
    })
    
    controller.present(alert, animated: true, completion: nil)
}

func showDeleteConfirmation(from controller: UIViewController,message: String,title: String, completion: @escaping (Bool) -> Void) {
    let alert = UIAlertController(
        title: "",
        message: message,
        preferredStyle: .alert
    )
    
    alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel) { _ in
        completion(false)
    })
    
    alert.addAction(UIAlertAction(title: title, style: .destructive) { _ in
        completion(true)
    })
    
    controller.present(alert, animated: true, completion: nil)
}

// MARK: - Helpers
public extension UIButton {
    func applyRoundedStyle() {
        titleLabel?.font = FontHelper.font(size: 16.0, type: .Regular)
        setRound(withBorderColor: .clear, andCornerRadious: 20.0, borderWidth: 0)
    }
}

public extension UITableViewCell {
    static var reuseIdentifier: String {
        String(describing: self)
    }
}


struct Formatter {
    // Core private formatter method to avoid duplication
    private static func formatNumber(_ number: NSNumber?,
                                     currencySymbol: String = "﷼",
                                     localeIdentifier: String = "en_SA") -> String {
        guard let number = number else {
            return "0 \(currencySymbol)"
        }
        
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: localeIdentifier)
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        let formatted = formatter.string(from: number) ?? "\(number)"
        return "\(formatted) \(currencySymbol)"
    }
    
    // Public method accepting String
    static func formatPrice(_ value: String?,
                            currencySymbol: String = "﷼",
                            localeIdentifier: String = "en_SA") -> String {
        guard let value = value,
              let doubleValue = Double(value) else {
            return "0 \(currencySymbol)"
        }
        return formatNumber(NSNumber(value: doubleValue), currencySymbol: currencySymbol, localeIdentifier: localeIdentifier)
    }
    
    // Public method accepting Double
    static func formatPrice(_ value: Double?,
                            currencySymbol: String = "﷼",
                            localeIdentifier: String = "en_SA") -> String {
        guard let value = value else {
            return "0 \(currencySymbol)"
        }
        return formatNumber(NSNumber(value: value), currencySymbol: currencySymbol, localeIdentifier: localeIdentifier)
    }
    
    // Calculate price per meter, inputs are strings (price and area)
    static func calculatePricePerMeter(price: Int?, area: Int?) -> String {
        guard let price = price, let area = area, area > 0 else {
            return "-"
        }
        let result = price / area
        return formatPriceNew("\(result)")
    }
}

func convertImageToBase64String(img: UIImage) -> String {
    return img.jpegData(compressionQuality: 0.6)?
        .base64EncodedString() ?? ""
}

func convertFileToBase64String(fileURL: URL) -> String? {
    do {
        let fileData = try Data(contentsOf: fileURL)
        return fileData.base64EncodedString()
    } catch {
        print("❌ Failed to read file data: \(error)")
        return nil
    }
}

extension UILabel {
    func applyStyle(size: CGFloat, color: UIColor) {
        font = FontHelper.font(size: size, type: .Regular)
        textColor = color
    }
}

extension UIViewController {
    
    func openPDF(url: URL) {
        
        let pdfVC = PDFPreviewController()
        pdfVC.pdfURL = url
        
        let nav = UINavigationController(rootViewController: pdfVC)
        nav.modalPresentationStyle = .fullScreen
        
        present(nav, animated: true)
    }
}
