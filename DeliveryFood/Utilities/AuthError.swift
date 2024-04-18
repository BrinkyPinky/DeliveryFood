//
//  AuthError.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 13.04.2024.
//

import Foundation

enum AuthError: Error {
    case invalidPhoneNumber, nameIsEmpty, failedToLoginAutomatically, failedToGetUserID
    
    var localizedDescription: String {
        switch self {
        case .invalidPhoneNumber: "Phone number is wrong formatted"
        case .nameIsEmpty: "Name must be provided"
        case .failedToLoginAutomatically: "Failed to log into account. The account details may have been changed or there may be no internet connection"
        case .failedToGetUserID: "Failed to retrieve user ID. Please log in to your account again"
        }
    }
}
