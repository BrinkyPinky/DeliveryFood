//
//  SearchAddressModel.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 07.04.2024.
//

import Foundation

struct SearchAddressModel: Identifiable {
    var id = UUID()
    let name: String
    let description: String
    let latitude: Double
    let longtitude: Double
    let kind: String
}
