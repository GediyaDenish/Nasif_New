//
//  UserDefaultsHelper.swift
//  Nasif
//
//  Created by Denish Gediya on 03/07/25.
//

import Foundation
import UIKit

// Property Wrapper for UserDefaults
@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T
    
    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    var wrappedValue: T {
        get {
            return UserDefaults.standard.value(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

class UserDefaultsHelper {
    
    static let shared = UserDefaultsHelper()
    
    // Token Property (using property wrapper)
    @UserDefault("token", defaultValue: "") var token: String
    @UserDefault("displayName", defaultValue: "") var displayName: String
    @UserDefault("topic", defaultValue: "") var topic: String
    
    static var token = ""
    static var displayName = ""
    
    // Method to remove token from UserDefaults
    func removeToken() {
        UserDefaults.standard.removeObject(forKey: "token")
        UserDefaults.standard.removeObject(forKey: "displayName")
        UserDefaults.standard.synchronize()
    }
        
    static func saveUserToDefaults(_ user: SignupResponse) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "savedUser")
        }
    }
    
    // Get User object from UserDefaults
    static func getUserFromDefaults() -> SignupResponse? {
        if let data = UserDefaults.standard.data(forKey: "savedUser") {
            return try? JSONDecoder().decode(SignupResponse.self, from: data)
        }
        return nil
    }
    
    // Remove User object from UserDefaults
    static func removeUserFromDefaults() {
        UserDefaults.standard.removeObject(forKey: "savedUser")
        token = ""
        displayName = ""
        UserDefaults.standard.synchronize()
    }
}
