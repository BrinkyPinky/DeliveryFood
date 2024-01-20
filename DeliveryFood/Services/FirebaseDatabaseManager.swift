//
//  FirebaseDatabaseManager.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 20.01.2024.
//

import Foundation
import FirebaseDatabase

enum FirebaseDatabaseErrors {
    case dataIsNotExist, unwrapError
    
    var message: String {
        switch self {
        case .dataIsNotExist: "Database error 'no data was found during download'"
        case .unwrapError: "Database error 'The data could not be unwrapped'"
        }
    }
}

class FirebaseDatabaseManager {
    static var shared = FirebaseDatabaseManager()
    
    var ref = Database.database().reference()
    
    func getCategories(completion: @escaping ([CategoryModel]) -> Void, completionError: @escaping (FirebaseDatabaseErrors) -> Void) {
        ref.child("categories").observeSingleEvent(of: .value) { dataSnapshot in
            guard dataSnapshot.exists() else {
                completionError(.dataIsNotExist)
                return
            }
            
            guard let data = dataSnapshot.value as? [String:[String:Any]] else {
                completionError(.unwrapError)
                return
            }
            
            var categories = [CategoryModel]()
            
            data.forEach({
                categories.append(CategoryModel(
                    id: $0.value["id"] as! Int,
                    url: $0.value["url"] as? String ?? "error",
                    name: $0.value["name"] as? String ?? "error"
                ))
            })
            
            completion(categories.sorted(by: {$0.id < $1.id}))
        }
    }
}
