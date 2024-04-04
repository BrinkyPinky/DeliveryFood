//
//  CoreDataError.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 02.04.2024.
//

import Foundation

enum CoreDataError: Error {
    case saveError, fetchError, addError, changeAmountError
    
    var localizedDescription: String {
        switch self {
        case .saveError: "There was an error with saving data.\nPlease report the bug."
        case .fetchError: "There was an error with retrieving shopping cart data.\nPlease report the bug"
        case .addError: "There was an error with adding to cart.\nPlease report the bug"
        case .changeAmountError: "There was an error with updating value.\nPlease report the bug"
        }
    }
}
