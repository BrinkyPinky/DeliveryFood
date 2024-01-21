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
    
    
    // MARK: Получить список категорий
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
    
    // MARK: Получить список блюд по ID категории
    func getFoodByCategoryId(_ id: Int, completion: @escaping ([DetailFoodModel]) -> Void, completionError: @escaping (FirebaseDatabaseErrors) -> Void) {
        ref.child("food/categoryid-\(id)").observeSingleEvent(of: .value) { dataSnapshot in
            guard dataSnapshot.exists() else {
                completionError(.dataIsNotExist)
                return
            }
            
            guard let data = dataSnapshot.value as? [String:[String:Any]] else {
                completionError(.unwrapError)
                return
            }
            
            var foods = [DetailFoodModel]()
            
            data.forEach {
                let ingredients = $0.value["ingredients"] as? String ?? "error, error"
                
                foods.append(
                    .init(
                        heading1: $0.value["heading1"] as? String ?? "error",
                        heading2: $0.value["heading2"] as? String ?? "error",
                        heading3: $0.value["heading3"] as? String ?? "error",
                        text1: $0.value["text1"] as? String ?? "error",
                        text2: $0.value["text2"] as? String ?? "error",
                        text3: $0.value["text3"] as? String ?? "error",
                        imageURL: $0.value["imageURL"] as? String ?? "error",
                        ingredients: ingredients.components(separatedBy: ", "),
                        name: $0.value["name"] as? String ?? "error",
                        price: $0.value["price"] as? Double ?? 0.0,
                        foodID: $0.value["foodID"] as? String ?? "error"
                    )
                )
            }
            
            completion(foods)
        }
    }
    
    func fillFoodInCategories() {
        ref.child("food/categoryid-0/burger0").setValue([
            "foodID": "burger0",
            "imageURL": "",
            "name": "Chefburger Junior",
            "price": "",
            "heading1": "Grams / Calories",
            "heading2": "PFC on 100g",
            "heading3": "Delivery in",
            "text1": "171gr / 219kcal",
            "text2": "P: 12.6G F: 8.9G C: 22.2G",
            "text3": "30 min",
            "ingredients": "",
        ])
    }
}
