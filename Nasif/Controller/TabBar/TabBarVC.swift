//
//  TabBarVC.swift
//  Nasif
//
//  Created by Denish Gediya on 21/06/25.
//

import UIKit

class TabBarVC: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        setupTabs()
        customizeAppearance()
        addTabBarTopSpacer()
        
        // ✅ Select last tab (Listings)
        self.selectedIndex = (self.viewControllers?.count ?? 1) - 1
        NotificationCenter.default.addObserver(self, selector: #selector(self.openController), name: NSNotification.Name(rawValue: "openController"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openChatController), name: NSNotification.Name(rawValue: "openChatController"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Add Observer only once
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUniversalLinkFromChat(_:)),
            name: Notification.Name("OpenGroupFromLink"),
            object: nil
        )
    }
    
    private func addTabBarTopSpacer() {
        let spacer = UIView()
        spacer.backgroundColor = .clear
        spacer.translatesAutoresizingMaskIntoConstraints = false
        tabBar.addSubview(spacer)
        
        NSLayoutConstraint.activate([
            spacer.topAnchor.constraint(equalTo: tabBar.topAnchor),
            spacer.leftAnchor.constraint(equalTo: tabBar.leftAnchor),
            spacer.rightAnchor.constraint(equalTo: tabBar.rightAnchor),
            spacer.heightAnchor.constraint(equalToConstant: 8)
        ])
    }
    
    @objc func openController(_ notification: Notification) {
        
        guard let chatMessage = notification.userInfo?["content"] as? ChatMessage else { return }
        
        // Move user to Chat tab first
        self.selectedIndex = 2
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { // ⏳ Increased delay → ensures UI ready
            
            guard let tabBarController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController else {
                print("❌ TabBarController not found")
                return
            }
            
            guard let navController = tabBarController.selectedViewController as? UINavigationController else {
                print("❌ Not a NavigationController")
                return
            }
            
            let storyboard = UIStoryboard(name: "Chat", bundle: nil)
            
            // 🔥 Prevent opening same chat again
            if let topVC = navController.topViewController as? GroupChatDetailVC,
               topVC.objChat?.id == chatMessage.id {
                print("⚠ Already on this group chat — not pushing again")
                return
            }
            
            // 🔥 New logic: Always open as group (since universal link is group invite)
            if let vc = storyboard.instantiateViewController(withIdentifier: "GroupChatDetailVC") as? GroupChatDetailVC {
                vc.objChat = chatMessage
                vc.hidesBottomBarWhenPushed = true
                navController.pushViewController(vc, animated: true)
            }
        }
    }
    
    @objc func openChatController(_ notification: Notification) {
        
        guard let chatMessage = notification.userInfo?["content"] as? ChatMessage else { return }
        
        // Move user to Chat tab first
        self.selectedIndex = 2
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { // ⏳ Increased delay → ensures UI ready
            
            guard let tabBarController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController else {
                print("❌ TabBarController not found")
                return
            }
            
            guard let navController = tabBarController.selectedViewController as? UINavigationController else {
                print("❌ Not a NavigationController")
                return
            }
            
            let storyboard = UIStoryboard(name: "Chat", bundle: nil)
            
            // 🔥 Prevent opening same chat again
            if let topVC = navController.topViewController as? ChatDetailVC,
               topVC.objChat?.id == chatMessage.id {
                print("⚠ Already on this group chat — not pushing again")
                return
            }
            
            // 🔥 New logic: Always open as group (since universal link is group invite)
            if let vc = storyboard.instantiateViewController(withIdentifier: "ChatDetailVC") as? ChatDetailVC {
                vc.objChat = chatMessage
                vc.hidesBottomBarWhenPushed = true
                navController.pushViewController(vc, animated: true)
            }
        }
    }
    
    
    @objc func handleUniversalLinkFromChat(_ notification: Notification) {
        
        guard let url = notification.userInfo?["url"] as? URL else { return }
        
        print("📩 Deep Link tapped from message:", url.absoluteString)
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let groupId = components.queryItems?.first(where: { $0.name == "groupId" })?.value else {
            print("❌ No groupId found in URL")
            return
        }
        
        // Move to Chat Tab
        self.selectedIndex = 2
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            DeepLinkManager.shared.joinGroup(
                groupId: groupId,
                window: UIApplication.shared.windows.first
            )
        }
    }
    
    
    private func setupTabs() {
        let storyboard = UIStoryboard(name: "Template", bundle: nil)
        
        guard
            let profileVC = storyboard.instantiateViewController(withIdentifier: "SettingVC") as? SettingVC,
            let dealsVC = storyboard.instantiateViewController(withIdentifier: "DealsVC") as? DealsVC,
            let chatVC = storyboard.instantiateViewController(withIdentifier: "ChatVC") as? ChatVC,
            let listingsVC = storyboard.instantiateViewController(withIdentifier: "ListingsVC") as? ListingsVC
        else {
            fatalError("Failed to instantiate view controllers from storyboard")
        }
        
        profileVC.tabBarItem = UITabBarItem(
            title: "Profile".localized,
            image: UIImage(named: "icn_profile")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "icn_profile_selected")?.withRenderingMode(.alwaysOriginal)
        )
        
        dealsVC.tabBarItem = UITabBarItem(
            title: "Deals".localized,
            image: UIImage(named: "icn_deals")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "icn_deals_selected")?.withRenderingMode(.alwaysOriginal)
        )
        
        chatVC.tabBarItem = UITabBarItem(
            title: "Chat".localized,
            image: UIImage(named: "icn_chat")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "icn_chat_selected")?.withRenderingMode(.alwaysOriginal)
        )
        
        listingsVC.tabBarItem = UITabBarItem(
            title: "Listings".localized,
            image: UIImage(named: "icn_listing")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "icn_listing_selected")?.withRenderingMode(.alwaysOriginal)
        )
        
        let nav1 = UINavigationController(rootViewController: profileVC)
        let nav2 = UINavigationController(rootViewController: dealsVC)
        let nav3 = UINavigationController(rootViewController: chatVC)
        let nav4 = UINavigationController(rootViewController: listingsVC)
        
        self.viewControllers = [nav1, nav2, nav3, nav4]
    }
    
    private func customizeAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.gray,
            .font: UIFont.systemFont(ofSize: 10)
        ]
        
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(named: "Primary_Color") ?? UIColor.systemBlue,
            .font: UIFont.boldSystemFont(ofSize: 10)
        ]
        
        appearance.stackedLayoutAppearance.normal.iconColor = nil
        appearance.stackedLayoutAppearance.selected.iconColor = nil
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
}
