//
//  ValidationExtension.swift
//  Nasif
//
//  Created by Denish Gediya on 03/07/25.
//

import Foundation
import UIKit

// MARK: - Validation Extension
extension String {
    func isEmpty() -> Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func isNumber() -> Bool {
        let numberCharacters = CharacterSet.decimalDigits.inverted
        return !self.isEmpty() && self.rangeOfCharacter(from: numberCharacters) == nil
    }
    
    func isValidMobileNumber() -> (Bool, String) {
        if self.isEmpty() {
            return (false, "Please enter a mobile number.".localized)
        } else {
            let min = 9
            let max = 12
            
            if self.count < min || self.count > max {
                return (false, "Please enter a valid mobile number.".localized)
            } else {
                return (true, "")
            }
        }
    }
}
