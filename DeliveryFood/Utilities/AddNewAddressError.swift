//
//  AddNewAddressError.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 06.04.2024.
//

import Foundation

enum AddNewAddressError: Error {
    case geopositionAccessError, unknownError, undeliverable
    
    var localizedDescription: String {
        switch self {
        case .geopositionAccessError: "You need to grant access to your location in the settings."
        case .unknownError: "Something went wrong.\nPlease report the bug"
        case .undeliverable: "We can't deliver here, try entering the address manually"
        }
    }
}
