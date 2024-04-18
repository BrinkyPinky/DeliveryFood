//
//  FirebaseStorageError.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 02.04.2024.
//

enum FirebaseFirestoreError: Error {
    case getDataError, dataProcessingError
    
    var localizedDescription: String {
        switch self {
        case .getDataError: "An error occurred while downloading data.\nPlease report the bug."
        case .dataProcessingError: "Unable to process data.\nPlease report the bug."
        }
    }
}
