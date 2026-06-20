//
//  CryptoManager.swift
//  Nasif
//
//  Created by Denish Gediya on 03/07/25.
//

import Foundation
import UIKit
import CryptoSwift

class CryptoManager {
    static var isEncryptionEnable: Bool = false
    static let secretKey = "fNRJDLaHCK30bqbE" // Replace with your secret key (16 characters for AES-128)

    static func encrypt(text: String) -> String? {
        do {
            let keyData = Array(secretKey.utf8)
            let aes = try AES(key: keyData, blockMode: ECB(), padding: .pkcs5)
            let encrypted = try aes.encrypt(Array(text.utf8))
            return Data(encrypted).base64EncodedString()
        } catch {
            printError("Encryption error: \(error)")
            return nil
        }
    }

    static func decrypt(text: String) -> String? {
        do {
            let keyData = Array(secretKey.utf8)
            let aes = try AES(key: keyData, blockMode: ECB(), padding: .pkcs5)
            let decrypted = try aes.decrypt(Array(Data(base64Encoded: text)!))
            return String(data: Data(decrypted), encoding: .utf8)
        } catch {
            printError("Decryption error: \(error)")
            return nil
        }
    }

    static func encryptParameters(_ paramData: [String: Any]?) -> [String: Any] {
        var encryptedParams: [String: Any] = [:]

        guard let paramData = paramData else {
            return encryptedParams
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: paramData, options: .prettyPrinted)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                if let encryptedText = encrypt(text: jsonString) {
                    encryptedParams = ["encryptedData": encryptedText]
                } else {
                    printError("Error encrypting data")
                }
            } else {
                printError("Error converting JSON to String")
            }
        } catch {
            printError("Error serializing JSON: \(error)")
        }
        return encryptedParams
    }

    static func decryptResponse(_ encryptedText: String) -> Data? {

        guard let encryptedData = Data(base64Encoded: encryptedText) else {
            printError("Error decoding base64 data from encrypted response")
            return nil
        }

        do {
            let keyData = Array(secretKey.utf8)
            let aes = try AES(key: keyData, blockMode: ECB(), padding: .pkcs5)
            let decryptedData = try aes.decrypt(Array(Data(base64Encoded: encryptedText)!))
            return Data(decryptedData)
        } catch {
            printError("Decryption error: \(error)")
            return nil
        }
    }
}

