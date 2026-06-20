//
//  DeepLinkManager.swift
//  Nasif
//
//  Created by Denish Gediya on 29/11/25.
//

import UIKit

class DeepLinkManager {
    
    static let shared = DeepLinkManager()
    
    func handle(url: URL, window: UIWindow?) {
        
        if let groupID = extractGroupID(from: url) {
            print("🎯 Extracted Group ID:", groupID)
            joinGroup(groupId: groupID, window: window)
        } else {
            print("❌ No GroupID Found")
        }
    }
    
    
    func extractGroupID(from url: URL) -> String? {
        
        // 🔥 1️⃣ First try direct extraction
        if let directGroupID = URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?
            .first(where: { $0.name == "groupId" })?.value {
            return directGroupID
        }
        
        // 🔥 2️⃣ If not direct, try redirect-based extraction
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let redirectValue = components.queryItems?.first(where: { $0.name == "redirect" })?.value else {
            return nil
        }
        
        guard let decodedRedirect = redirectValue.removingPercentEncoding else { return nil }
        
        guard let redirectURL = URL(string: "https://placeholder.com\(decodedRedirect)"),
              let redirectComponents = URLComponents(url: redirectURL, resolvingAgainstBaseURL: false),
              let groupID = redirectComponents.queryItems?.first(where: { $0.name == "groupId" })?.value else {
            return nil
        }
        
        return groupID
    }

    
    func joinGroup(groupId: String, window: UIWindow?) {
        Utility.showLoading()
        
        WebServices.Put(url: "\(WebService.CHATS)\(groupId)/join/",
                        params: [:],
                        type: ChatMessage.self) { response in
            Utility.hideLoading()
            
            guard var chatObj = response else {
                Utility.showToast(message: "Failed to join group.".localized)
                return
            }

            // 🔥 Ensure this is treated as GROUP
            chatObj.isGroup = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                NotificationCenter.default.post(name: NSNotification.Name("openController"),
                                                object: nil,
                                                userInfo: ["content": chatObj])
            }
        }
    }

}
