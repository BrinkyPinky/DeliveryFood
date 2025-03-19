//
//  CategoryModel.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 20.01.2024.
//

import Foundation

struct CategoryModel: Decodable, Encodable, Hashable {
    var id: String
    var name: String
    var order: Int
}
