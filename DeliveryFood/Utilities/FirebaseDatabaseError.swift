//
//  FirebaseDatabaseError.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 02.04.2024.
//

import Foundation

enum FirebaseDatabaseError: Error, LocalizedError {
    case dataIsNotExistError, unwrapError
    
    var errorDescription: String? {
        switch self {
        case .dataIsNotExistError: "Data could not be retrieved or does not exist.\nPlease report the bug."
        case .unwrapError: "Failed to unwrap data.\nPlease report the bug."
        }
    }
}
