//
//  PositionForBillModel+CoreDataProperties.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 31.03.2024.
//
//

import Foundation
import CoreData


extension PositionForBillModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PositionForBillModel> {
        return NSFetchRequest<PositionForBillModel>(entityName: "PositionForBillModel")
    }

    @NSManaged public var foodName: String
    @NSManaged public var foodID: String
    @NSManaged public var price: Double
    @NSManaged public var amount: Int16
    @NSManaged public var timestamp: Date
    @NSManaged public var referenceForItself: String

}

extension PositionForBillModel : Identifiable {

}
