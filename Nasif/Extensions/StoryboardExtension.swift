//
//  StoryboardExtension.swift
//  Nasif
//
//  Created by Denish Gediya on 03/07/25.
//

import Foundation
import UIKit

enum AppStoryboard: String {
    case Main
    
    var instance: UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }
}


extension UIResponder {
    
    static func getTopNavigationController() -> UINavigationController? {
        
        guard let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.windows.first?.rootViewController })
            .first else { return nil }
        
        
        if let nav = rootVC as? UINavigationController { return nav }
        
        if let tab = rootVC as? UITabBarController,
           let nav = tab.selectedViewController as? UINavigationController { return nav }
        
        if let nav = rootVC.presentedViewController as? UINavigationController { return nav }
        
        return nil
    }
}
