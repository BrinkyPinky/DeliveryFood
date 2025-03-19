//
//  DetailFoodModel.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 21.01.2024.
//

import Foundation

struct DetailFoodModel: Decodable, Encodable, Equatable {
    var heading1, heading2, heading3: String
    var text1, text2, text3: String
    var categoryID: String
    var orderInCategory: Int

    var ingredients: [String]
    var name: String
    var price: Double

    var foodID: String

    static let mock = DetailFoodModel(
        heading1: "Grams / Calories", heading2: "PFC on 100g",
        heading3: "Delivery in", text1: "940gr / 219kcal",
        text2: "P: 8.8G F: 7.3G C: 28.1G",
        text3: "30 min", categoryID: "hcXCbYcOuF5TZp79rjQs",
        orderInCategory: 0,
        ingredients: [
            "Spicy chorizo", "Hot jalapeño peppers", "BBQ sauce", "Beef mitts",
            "Tomatoes", "Sweet peppers", "Red onions", "Mozzarella",
            "Tomato sauce",
        ], name: "Diablo",
        price: 12,
        foodID: "0kDMwsCa7zvExU4N9x8Q")
}
