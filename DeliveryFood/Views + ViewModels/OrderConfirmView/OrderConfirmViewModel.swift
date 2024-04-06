//
//  OrderConfirmViewModel.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 05.04.2024.
//

import Foundation

protocol DeliverDetailTypes {}

enum DeliveryTimeType: DeliverDetailTypes {
    case ASAP, onTime
}

enum PaymentType: DeliverDetailTypes {
    case card, cash
}

final class OrderConfirmViewModel: ObservableObject {
    //Details
    @Published var deliveryTimeType = DeliveryTimeType.ASAP
    @Published var selectedDate = Date()
    @Published var paymentType = PaymentType.card
    @Published var pickedAdressTag = 1
    
    func changeDeliverDetailTypes(newType: DeliverDetailTypes) {
        if let newType = newType as? DeliveryTimeType {
            deliveryTimeType = newType
        } else if let newType = newType as? PaymentType {
            paymentType = newType
        }
    }
}
