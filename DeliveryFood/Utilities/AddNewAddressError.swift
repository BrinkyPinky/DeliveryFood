//
//  AddNewAddressError.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 06.04.2024.
//

import Foundation

enum AddNewAddressError: Error {
    case geopositionAccessError, unknownError, undeliverable, gettingDataError, JSONDataProcessingError, invalidAddress
    
    var localizedDescription: String {
        switch self {
        case .geopositionAccessError: "You need to grant access to your location in the settings."
        case .unknownError: "Something went wrong."
        case .undeliverable: "We can't deliver here, try entering the address manually"
        case .gettingDataError: "It is impossible to get data from API.\nPlease report the bug"
        case .JSONDataProcessingError: "Error with JSON Data processing.\nPlease report the bug"
        case .invalidAddress: "The address is not accurate. Please provide the house number"
        }
    }
}
