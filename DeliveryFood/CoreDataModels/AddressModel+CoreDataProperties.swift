//
//  AddressModel+CoreDataProperties.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 07.04.2024.
//
//

import Foundation
import CoreData


extension AddressModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AddressModel> {
        return NSFetchRequest<AddressModel>(entityName: "AddressModel")
    }

    @NSManaged public var addressString: String?
    @NSManaged public var apartment: String?
    @NSManaged public var entranceway: String?
    @NSManaged public var floor: String?
    @NSManaged public var intercomNumber: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longtitude: Double
    @NSManaged public var orderComment: String?

}

extension AddressModel : Identifiable {

}
