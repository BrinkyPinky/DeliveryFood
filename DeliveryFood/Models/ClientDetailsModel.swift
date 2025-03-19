//
//  ClientDetailsModel.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 17.03.2025.
//

import Foundation

struct ClientDetailsModel: Decodable {
    let email: String
    let name: String
    let phoneNumber: String
    
    static let loadingData = ClientDetailsModel(email: "Loading...", name: "Loading...", phoneNumber: "Loading...")
}
