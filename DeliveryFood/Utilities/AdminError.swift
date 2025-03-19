//
//  AdminErrors.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 17.03.2025.
//

import Foundation

enum AdminError: Error, LocalizedError {
    case getUserDataError, JSONEncoderError, updateNewOrderStatusError, uploadOnServerError, imageConvertError, unfilledFieldsError
    
    var errorDescription: String? {
        switch self {
        case .getUserDataError: return "Failed to retrieve user details"
        case .JSONEncoderError: return "Failed to encode the data for sending"
        case .updateNewOrderStatusError: return "Failed to update order status"
        case .uploadOnServerError: return "Failed to upload data on server"
        case .imageConvertError: return "Failed to convert the photo to the desired format"
        case .unfilledFieldsError: return "The fields must be filled in"
        }
    }
}
