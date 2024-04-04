//
//  FirebaseStorageError.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 02.04.2024.
//

enum FirebaseStorageError: Error {
    case getDataError
    
    var localizedDescription: String {
        switch self {
        case .getDataError: "An error occurred while downloading images\nPlease report the bug."
        }
    }
}
