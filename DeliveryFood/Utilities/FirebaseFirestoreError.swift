//
//  FirebaseStorageError.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 02.04.2024.
//

import Foundation

enum FirebaseFirestoreError: Error, LocalizedError {
    case getDataError, dataProcessingError
    
    var errorDescription: String? {
        switch self {
        case .getDataError: return "An error occurred while downloading data.\nPlease report the bug."
        case .dataProcessingError: return "Unable to process data.\nPlease report the bug."
        }
    }
}
