//
//  String+Extension.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 16.04.2024.
//

import Foundation

extension String {
    func isPhoneNumberValid() -> Bool {
        let phoneRegex = #"^\+\d{1,3}[- ]?\(?\d{3}\)?[- ]?\d{3}[- ]?\d{2}[- ]?\d{2}$"#

        guard let regex = try? NSRegularExpression(pattern: phoneRegex) else {
            return false
        }
        
        let range = NSRange(location: 0, length: self.utf16.count)
        return regex.firstMatch(in: self, range: range) != nil
    }
    
    func formatStringToPhoneNumber() -> String {
        var formattedNumber = self.replacingOccurrences(of: "[^+0-9]", with: "", options: .regularExpression)
        
        if formattedNumber.count >= 3 {
            formattedNumber.insert(" ", at: formattedNumber.index(formattedNumber.startIndex, offsetBy: 2))
            formattedNumber.insert("(", at: formattedNumber.index(formattedNumber.startIndex, offsetBy: 3))
        }
        if formattedNumber.count >= 8 {
            formattedNumber.insert(")", at: formattedNumber.index(formattedNumber.startIndex, offsetBy: 7))
            formattedNumber.insert(" ", at: formattedNumber.index(formattedNumber.startIndex, offsetBy: 8))
        }
        if formattedNumber.count >= 13 {
            formattedNumber.insert("-", at: formattedNumber.index(formattedNumber.startIndex, offsetBy: 12))
        }
        if formattedNumber.count >= 16 {
            formattedNumber.insert("-", at: formattedNumber.index(formattedNumber.startIndex, offsetBy: 15))
        }
        
        return String(formattedNumber.prefix(18))
    }
}
