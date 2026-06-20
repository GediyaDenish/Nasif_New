//
//  AppDelegate.swift
//  Nasif
//
//  Created by Denish Gediya on 21/06/25.
//

import UIKit
import IQKeyboardManagerSwift
import GoogleMaps
import GooglePlaces
import UserNotifications
import FirebaseCore
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    
    // MARK: - Application Launch
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // MARK: IQKeyboard Setup
        setupIQKeyboard()
        UIView.appearance().semanticContentAttribute = .forceLeftToRight
        // MARK: Google API Keys
        GMSServices.provideAPIKey("AIzaSyBDMdhd2RszlsxkRSkf3EByTG1ZPIxjOI8")
        GMSPlacesClient.provideAPIKey("AIzaSyBDMdhd2RszlsxkRSkf3EByTG1ZPIxjOI8")
        
        // MARK: Firebase Setup
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        
        // MARK: Notification Setup
        setupNotifications(application)
        
        return true
    }
    
    // MARK: Scene Configuration
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) { }
    
    // MARK: Remote Notification Registration
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        print("✅ APNs token: \(deviceToken.map { String(format: "%02.2hhx", $0) }.joined())")
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    // MARK: Handle FCM Message (Foreground/Background)
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        handleNotification(userInfo: userInfo)
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async -> UIBackgroundFetchResult {
        handleNotification(userInfo: userInfo)
        return .newData
    }
    
    // MARK: Custom Helpers
    func setupIQKeyboard() {
        IQKeyboardManager.shared.enableAutoToolbar = false
        UITextField.appearance().tintColor = UIColor.black
        IQKeyboardManager.shared.toolbarConfiguration.placeholderConfiguration.showPlaceholder = false
        IQKeyboardManager.shared.toolbarConfiguration.previousNextDisplayMode = .alwaysHide
        IQKeyboardManager.shared.resignOnTouchOutside = true
        IQKeyboardManager.shared.isEnabled = true
    }
    
    func setupNotifications(_ application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
        
        Task {
            do {
                let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
                if granted {
                    await MainActor.run {
                        application.registerForRemoteNotifications()
                    }
                    print("✅ Notification permission granted")
                } else {
                    print("⚠️ Notification permission denied")
                }
            } catch {
                print("❌ Notification permission request failed: \(error)")
            }
        }
    }
    
    func handleNotification(userInfo: [AnyHashable: Any]) {
        if let messageID = userInfo[gcmMessageIDKey] {
            print("📩 Message ID: \(messageID)")
        }
        print("🔔 Full Notification: \(userInfo)")
    }
    
    static func SharedApplication() -> AppDelegate {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("❌ Unable to get shared AppDelegate instance.")
        }
        return delegate
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // MARK: Foreground Notification Display
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.alert, .sound, .badge]
    }
    
    // MARK: Notification Tap Handling
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        if let chatId = userInfo["chat"] as? String {
            getChat(id: chatId)
        }
    }
}

extension AppDelegate: MessagingDelegate {
    
    // MARK: Firebase FCM Token Handling
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        print("📱 Firebase registration token: \(fcmToken)")
        WebService.firebaseMessaging = messaging
        // Store / Send to backend
        UserDefaults.standard.setValue(fcmToken, forKey: "fcmToken")
        
        // Topic subscription example
        if let topic = UserDefaultsHelper.shared.topic as? String {
            messaging.subscribe(toTopic: topic)
            print("✅ Subscribed to topic: \(topic)")
        }
    }
}

extension AppDelegate {
    
    // MARK: Handle Chat Navigation
    func getChat(id: String) {
        WebServices.Get(url: "\(WebService.CHATS)\(id)/", type: ChatMessage.self) { response in
            guard let chatDetail = response else { return }
            if chatDetail.isGroup ?? false {
                NotificationCenter.default.post(name: NSNotification.Name("openController"),
                                                object: nil,
                                                userInfo: ["content": chatDetail])
            } else {
                NotificationCenter.default.post(name: NSNotification.Name("openChatController"),
                                                object: nil,
                                                userInfo: ["content": chatDetail])
            }
        }
    }
}
