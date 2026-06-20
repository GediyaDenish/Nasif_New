//
//  SceneDelegate.swift
//  Nasif
//
//  Created by Denish Gediya on 21/06/25.
//

import UIKit
import FirebaseMessaging

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var lastOpenedURL: URL?
    
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        window.rootViewController = UIViewController()
        window.backgroundColor = .white
        window.makeKeyAndVisible()
        
        DispatchQueue.main.async {
            self.initialSetup()
        }
        
        if let userActivity = connectionOptions.userActivities.first,
           let url = userActivity.webpageURL {
            
            // Store deep link URL globally
            self.lastOpenedURL = url
            
            // Save for later join if user not logged in
            if UserDefaultsHelper.shared.token.isEmpty {
                UserDefaults.standard.set(url.absoluteString, forKey: "pendingDeepLink")
            }
        }
    }
    
    // MARK: - Universal Link Handler
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard let url = userActivity.webpageURL else { return }
        
        print("🌍 Universal Link received:", url.absoluteString)
        lastOpenedURL = url
        
        if UserDefaultsHelper.shared.token.isEmpty {
            // Save for post login join
            UserDefaults.standard.set(url.absoluteString, forKey: "pendingDeepLink")
        } else {
            // User logged in → join now
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                DeepLinkManager.shared.handle(url: url, window: self.window)
            }
        }
    }
    
    // MARK: - App Navigation
    func gotoLogin() {
        guard let window = window else { return }
        
        let loginVC = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        
        setRoot(UINavigationController(rootViewController: loginVC))
    }
    
    
    func gotoTabbar() {
        setRoot(TabBarVC())
        
        // 🔥 Check if deep link was pending
        if let savedURL = UserDefaults.standard.string(forKey: "pendingDeepLink"),
           let url = URL(string: savedURL) {
            
            print("▶️ Processing pending deep link:", savedURL)
            
            UserDefaults.standard.removeObject(forKey: "pendingDeepLink")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                DeepLinkManager.shared.handle(url: url, window: self.window)
            }
        } else if let url = lastOpenedURL {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                DeepLinkManager.shared.handle(url: url, window: self.window)
            }
        }
    }
    
    
    func setRoot(_ vc: UIViewController) {
        guard let window = window else { return }
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
            window.rootViewController = vc
        }
        window.makeKeyAndVisible()
    }
    
    
    // MARK: - App State Logic
    func initialSetup() {
        let token = UserDefaultsHelper.shared.token
        
        if token.isEmpty {
            gotoLogin()
        } else {
            getProfile()
            gotoTabbar()
        }
    }
    
    func getProfile() {
        WebServices.Get(url: WebService.PROFILE, type: UserModel.self) { [weak self] (response: UserModel?) in
            guard let self = self else { return }
            guard let response = response else { return }
            let _ = SocketService.init()
            let topic = response.id.replacingOccurrences(of: "-", with: "")
            UserDefaultsHelper.shared.topic = topic
            Messaging.messaging().subscribe(toTopic: topic)
        }
    }
}
