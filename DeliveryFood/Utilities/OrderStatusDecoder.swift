//
//  OrderStatusDecoder.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 16.04.2024.
//

import Foundation

final class OrderStatusDecoder {
    func decode(_ orderStatus: Int) -> String {
        switch orderStatus {
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

OrderStatusDecoder().decode(1)
