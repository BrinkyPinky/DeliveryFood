//
//  AdminOrderModel.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 14.03.2025.
//

import Foundation

struct AdminOrderModel: Decodable {
    let date: Date
    let totalPrice: Double
    var orderStatus: Int
    let positions: [AdminOrderPosition]
    let orderID: String

    let address: String
    let apartment: String
    let entranceway: String
    let floor: String
    let intercom: String
    let orderComment: String
    let paymentType: String
    let userID: String

    let ordersByDatesRef: String
    let ordersByUsersRef: String

    static let mock = AdminOrderModel(
        date: Date(), totalPrice: 20.00, orderStatus: 0, positions: [AdminOrderPosition(foodName: "Chefburger Junior", amount: 20, foodID: "smth", price: 20.20, referenceForItself: "rwoqkro")],
        orderID: "4102940irwqirou", address: "rqwoijrqwojriwq", apartment: "24",
        entranceway: "12", floor: "", intercom: "24",
        orderComment: "rojroqwjoir", paymentType: "By Card", userID: "2FLmLUWNenAFhGjLdZ4rdFBfxpiEF3",
        ordersByDatesRef: "rqwojroiwqjiorjqwijirowjqo",
        ordersByUsersRef: "rwqoijriwqoijroiqwoirqwik")
}

struct AdminOrderPosition: Decodable {
    let foodName: String
    let amount: Int
    let foodID: String
    let price: Double
    let referenceForItself: String
}
