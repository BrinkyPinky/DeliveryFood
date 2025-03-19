//
//  Int+OrderStatusDecoder.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 14.03.2025.
//

import Foundation

extension Int {
    func orderStatusDecode() -> String {
        switch self {
        case -1: return "Canceled"
        case 0: return "Ordered"
        case 1: return "Accepted"
        case 2: return "Cooking"
        case 3: return "Delivering"
        case 4: return "Delivered"
        default: return "Unknown status"
        }
    }
}
