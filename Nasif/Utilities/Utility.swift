//
//  Utility.swift
//  Nasif
//
//  Created by Denish Gediya on 03/07/25.
//

import Foundation
import UIKit
import PDFKit
import AVKit
import AVFoundation

extension UIApplication {
    // Helper to get the topmost window
    var currentWindow: UIWindow? {
        return connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first
    }
}

class Utility: NSObject {
    
    static var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    static var overlayView = UIView()
    static var mainView = UIView()
    
    override init() {
        // initilizer
    }
    
    static func showLoading(color: UIColor = UIColor.white, text: String? = nil) {
        DispatchQueue.main.async {
            if !activityIndicator.isAnimating {
                self.mainView = UIView()
                self.mainView.frame = UIScreen.main.bounds
                self.mainView.backgroundColor = UIColor.clear
                self.overlayView = UIView()
                self.activityIndicator = UIActivityIndicatorView()
                
                let maxWidth = UIScreen.main.bounds.width * 0.8
                
                overlayView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
                overlayView.backgroundColor = UIColor(white: 0, alpha: 0.7)
                overlayView.clipsToBounds = true
                overlayView.layer.cornerRadius = 10
                overlayView.layer.zPosition = 1
                
                activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
                activityIndicator.style = .large
                activityIndicator.color = .white
                overlayView.addSubview(activityIndicator)
                activityIndicator.center = CGPoint(x: overlayView.bounds.width / 2, y: overlayView.bounds.height / 2)
                
                if text != nil {
                    let lblTxt = UILabel(frame: CGRect(x: 10, y: activityIndicator.frame.size.height + activityIndicator.frame.origin.y + CGFloat(8), width: maxWidth - 20, height: 23))
                    overlayView.addSubview(lblTxt)
                    lblTxt.text = text!
                    lblTxt.numberOfLines = 2
                    lblTxt.font = FontHelper.font(type: .Regular)
                    lblTxt.textColor = color
                    lblTxt.sizeToFit()
                    lblTxt.textAlignment = .center
                    if lblTxt.frame.size.width > 80 {
                        overlayView.frame.size.width = lblTxt.frame.size.width + 20
                    } else {
                        overlayView.frame.size.width = 80
                    }
                    overlayView.frame.size.height = lblTxt.frame.size.height + lblTxt.frame.origin.y + CGFloat(20)
                    activityIndicator.center = CGPoint(x: overlayView.bounds.width / 2, y: activityIndicator.center.y)
                }
                
                self.mainView.addSubview(overlayView)
                
                if let vw = APPDELEGATE.window?.viewWithTag(701) {
                    APPDELEGATE.window?.bringSubviewToFront(vw)
                } else {
                    overlayView.center = UIApplication.shared.currentWindow?.center ?? CGPoint(x: 0, y: 0)
                    mainView.tag = 701
                    UIApplication.shared.currentWindow?.addSubview(mainView)
                    activityIndicator.startAnimating()
                }
            } else {
                if let vw = APPDELEGATE.window?.viewWithTag(701) {
                    APPDELEGATE.window?.bringSubviewToFront(vw)
                }
            }
        }
    }
    
    static func hideLoading() {
        DispatchQueue.main.async {
            activityIndicator.stopAnimating()
            UIApplication.shared.currentWindow?.viewWithTag(701)?.removeFromSuperview()
        }
    }
    
    static func showToast(message: String, backgroundColor: UIColor = .black, textColor: UIColor = .white) {
        guard !message.isEmpty else { return }
        
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.currentWindow else { return }
            
            var bottomPadding: CGFloat = 0
            if window.safeAreaInsets.bottom > 0 {
                bottomPadding = window.safeAreaInsets.bottom
            }
            
            let label = UILabel()
            label.textAlignment = .center
            label.text = message
            label.numberOfLines = 4
            label.textColor = textColor
            label.backgroundColor = backgroundColor
            label.alpha = 1
            label.sizeToFit()
            label.frame.size.width = UIScreen.main.bounds.width
            label.frame.origin.y = 8
            
            let contentView = UIView()
            contentView.backgroundColor = backgroundColor
            contentView.layer.shadowColor = UIColor.gray.cgColor
            contentView.layer.shadowOffset = CGSize(width: 4, height: 3)
            contentView.layer.shadowOpacity = 0.3
            
            contentView.addSubview(label)
            
            UIApplication.shared.currentWindow?.endEditing(true)
            
            let appDelegateWindow = (UIApplication.shared.delegate as? AppDelegate)?.window ?? window
            let fullWidth = appDelegateWindow.frame.width
            let maxY = appDelegateWindow.frame.maxY
            
            let height = (bottomPadding > 0 ? 0 : 16) + label.frame.height + bottomPadding
            contentView.frame = CGRect(x: 0, y: maxY, width: fullWidth, height: height)
            
            window.addSubview(contentView)
            
            var showFrame = contentView.frame
            showFrame.origin.y = maxY - contentView.frame.height
            
            UIView.animate(withDuration: 3.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
                contentView.frame = showFrame
            }, completion: { _ in
                UIView.animate(withDuration: 3.0, delay: 3.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: .curveEaseIn, animations: {
                    contentView.alpha = 0
                }, completion: { _ in
                    contentView.removeFromSuperview()
                })
            })
        }
    }
    
    static func showNewToast(message: String, backgroundColor: UIColor = UIColor.themePrimaryColor, textColor: UIColor = .white) {
        guard !message.isEmpty else { return }
        
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.currentWindow else { return }
            
            var bottomPadding: CGFloat = 0
            if window.safeAreaInsets.bottom > 0 {
                bottomPadding = window.safeAreaInsets.bottom
            }
            
            let label = UILabel()
            label.textAlignment = .center
            label.text = message
            label.numberOfLines = 4
            label.textColor = textColor
            label.backgroundColor = backgroundColor
            label.alpha = 1
            label.sizeToFit()
            label.frame.size.width = UIScreen.main.bounds.width
            label.frame.origin.y = 8
            
            let contentView = UIView()
            contentView.backgroundColor = backgroundColor
            contentView.layer.shadowColor = UIColor.gray.cgColor
            contentView.layer.shadowOffset = CGSize(width: 4, height: 3)
            contentView.layer.shadowOpacity = 0.3
            
            contentView.addSubview(label)
            
            UIApplication.shared.currentWindow?.endEditing(true)
            
            let appDelegateWindow = (UIApplication.shared.delegate as? AppDelegate)?.window ?? window
            let fullWidth = appDelegateWindow.frame.width
            let maxY = appDelegateWindow.frame.maxY
            
            let height = (bottomPadding > 0 ? 0 : 16) + label.frame.height + bottomPadding
            contentView.frame = CGRect(x: 0, y: maxY, width: fullWidth, height: height)
            
            window.addSubview(contentView)
            
            var showFrame = contentView.frame
            showFrame.origin.y = maxY - contentView.frame.height
            
            UIView.animate(withDuration: 3.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
                contentView.frame = showFrame
            }, completion: { _ in
                UIView.animate(withDuration: 3.0, delay: 3.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: .curveEaseIn, animations: {
                    contentView.alpha = 0
                }, completion: { _ in
                    contentView.removeFromSuperview()
                })
            })
        }
    }
    
    static func signOut() {
        Utility.showLoading()
        Utility.showToast(message: "Logout account successfully".localized)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            Utility.hideLoading()
            if let topic = UserDefaultsHelper.shared.topic as? String{
                WebService.firebaseMessaging?.unsubscribe(fromTopic: topic)
            }
            if let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC, let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate{
                UserDefaultsHelper.shared.removeToken()
                UserDefaultsHelper.removeUserFromDefaults()
                sceneDelegate.window?.rootViewController = UINavigationController(rootViewController: vc)
            }
        }
    }
    
    static func showNetworkAlert(on vc: UIViewController, retryHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: "No Internet", message: "Please check your internet connection and try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in
            retryHandler()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        vc.present(alert, animated: true)
    }
    
    static func showToastss(message: String) {
        print("🍞 TOAST: \(message)")
    }
    
    static func generateThumbnail(url: URL, completion: @escaping (UIImage?) -> Void) {
        let asset = AVURLAsset(url: url) // iOS 18+ recommended
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        let time = CMTime(seconds: 1, preferredTimescale: 2)
        
        if #available(iOS 18.0, *) {
            // iOS 18+ async generator
            imageGenerator.generateCGImageAsynchronously(for: time) { cgImage, _, error in
                var thumbnail: UIImage? = nil
                if let cgImage = cgImage {
                    thumbnail = UIImage(cgImage: cgImage)
                }
                if let error = error {
                    print("❌ Thumbnail generation failed:", error)
                }
                DispatchQueue.main.async {
                    completion(thumbnail)
                }
            }
        } else {
            // Fallback for iOS < 18
            DispatchQueue.global().async {
                do {
                    let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                    let thumbnail = UIImage(cgImage: cgImage)
                    DispatchQueue.main.async {
                        completion(thumbnail)
                    }
                } catch {
                    print("❌ Thumbnail generation failed:", error)
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
        }
    }
    
    static func generatePDFThumbnail(from url: URL, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let pdfDocument = PDFDocument(url: url),
                  let page = pdfDocument.page(at: 0) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            let pageRect = page.bounds(for: .mediaBox)
            let renderer = UIGraphicsImageRenderer(size: pageRect.size)
            
            let img = renderer.image { ctx in
                UIColor.white.set()
                ctx.fill(pageRect)
                ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
                ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
                page.draw(with: .mediaBox, to: ctx.cgContext)
            }
            
            DispatchQueue.main.async {
                completion(img)
            }
        }
    }
    
    // Remove user
    static func clearUserFromDefaults() {
        UserDefaults.standard.removeObject(forKey: "savedUser")
    }
    
    public typealias AlertHandler = (Bool) -> Void
    
    public class func showAlert(description: String, completionHandler: AlertHandler? = nil) {
        let alertController = UIAlertController(title: "Nasif", message: description, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler?(true)
        }
        alertController.addAction(okAction)
        
        if let topVC = UIApplication.getTopViewController() {
            topVC.present(alertController, animated: true, completion: nil)
        } else {
            print("⚠️ Could not find a top view controller to present the alert.")
        }
    }
    
    static func addIfValid(_ dict: inout [String: Any], key: String, value: Any?) {
        if let str = value as? String, !str.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            // Only add non-empty string
            dict[key] = str
        } else if let intVal = value as? Int, intVal >= 0 { // ✅ 0 allow karva
            dict[key] = intVal
        } else if let arr = value as? [Any], !arr.isEmpty {
            // Only add non-empty arrays
            let filtered = arr.compactMap { ($0 as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            if !filtered.isEmpty {
                dict[key] = filtered
            }
        }
    }
    
    static func toggleSelection(item: String, selectedArray: inout [String]) {
        if let index = selectedArray.firstIndex(of: item) {
            selectedArray.remove(at: index)
        } else {
            selectedArray.append(item)
        }
    }
    
    static func formattedPhoneNumber(_ number: String?) -> String {
        guard var mobile = number?.trimmingCharacters(in: .whitespacesAndNewlines), !mobile.isEmpty else { return "" }
        
        // remove all symbols / spaces
        mobile = mobile.replacingOccurrences(of: " ", with: "")
        mobile = mobile.replacingOccurrences(of: "+", with: "")
        
        // detect country
        var countryCode = ""
        
        if mobile.hasPrefix("5") || mobile.hasPrefix("05") {
            // Saudi (local starts with 5)
            countryCode = "+966"
        } else if mobile.hasPrefix("6") || mobile.hasPrefix("7") || mobile.hasPrefix("8") || mobile.hasPrefix("9") {
            countryCode = "+91"
        }
        
        // attach country prefix if not exists
        if !mobile.hasPrefix("966") && countryCode == "+966" {
            mobile = "966" + mobile
        } else if !mobile.hasPrefix("91") && countryCode == "+91" {
            mobile = "91" + mobile
        }
        
        // final formatting
        if countryCode == "+966" {    // Saudi format => +966 55 288 5210
            if mobile.count >= 12 {
                let country = String(mobile.prefix(3)) //966
                let p1 = String(mobile.dropFirst(3).prefix(2))
                let p2 = String(mobile.dropFirst(5).prefix(3))
                let p3 = String(mobile.dropFirst(8).prefix(4))
                return "+\(country) \(p1) \(p2) \(p3)"
            }
        } else if countryCode == "+91" { // India format => +91 98765 43210
            if mobile.count >= 12 {
                let country = String(mobile.prefix(2)) //91
                let p1 = String(mobile.dropFirst(2).prefix(5))
                let p2 = String(mobile.dropFirst(7).prefix(5))
                return "+\(country) \(p1) \(p2)"
            }
        }
        
        // fallback
        return "+" + mobile
    }
    
}

extension UIApplication {
    class func getTopViewController(base: UIViewController? = {
        return UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.windows.first(where: \.isKeyWindow)?.rootViewController }
            .first
    }()) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)
        }
        
        if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        
        return base
    }
}
