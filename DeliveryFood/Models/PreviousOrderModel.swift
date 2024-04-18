//
//  PreviousOrderModel.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 14.04.2024.
//

import Foundation

struct PreviousOrderModel: Decodable {
    var date: Date
    var totalPrice: Double
    var orderStatus: Int
    var positions: [PreviousOrderPosition]
}

struct PreviousOrderPosition: Decodable {
    var foodName: String
    var amount: Int
    var foodID: String
    var price: Double
    var referenceForItself: String
}
