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
            
            completion(foods.sorted(by: {$0.foodID < $1.foodID}))
        }
    }
    
    func fillFoodInCategories() {
        ref.child("food/categoryid-0/burger0").setValue([
            "foodID": "burger0",
            "imageURL": "gs://deliveryfood-db5c8.appspot.com/food/burgers/Chefburger Junior.png",
            "name": "Chefburger Junior",
            "price": 2.10,
            "heading1": "Grams / Calories",
            "heading2": "PFC on 100g",
            "heading3": "Delivery in",
            "text1": "171gr / 219kcal",
            "text2": "P: 12.6G F: 8.9G C: 22.2G",
            "text3": "30 min",
            "ingredients": "Bun with sesame, Strips OR, Caesar sauce, Tomatoes, lettuce",
        ])
        ref.child("food/categoryid-0/burger1").setValue([
            "foodID": "burger1",
            "imageURL": "gs://deliveryfood-db5c8.appspot.com/food/burgers/Longer Special.png",
            "name": "Longer Special",
            "price": 1.40,
            "heading1": "Grams / Calories",
            "heading2": "PFC on 100g",
            "heading3": "Delivery in",
            "text1": "101gr / 229kcal",
            "text2": "P: 10.7G F: 9.2G C: 25.8G",
            "text3": "30 min",
            "ingredients": "Danish Hot Dog Bun, Bites, Mayo sauce, Mustard sauce, Pickles, Onion",
        ])
        ref.child("food/categoryid-0/burger2").setValue([
            "foodID": "burger2",
            "imageURL": "gs://deliveryfood-db5c8.appspot.com/food/burgers/Big Maestro.png",
            "name": "Big Maestro",
            "price": 4.50,
            "heading1": "Grams / Calories",
            "heading2": "PFC on 100g",
            "heading3": "Delivery in",
            "text1": "277gr / 232kcal",
            "text2": "P: 12.8G F: 10.1G C: 22.5G",
            "text3": "30 min",
            "ingredients": "Brioche bun, Classic Burger sauce, Fresh tomatoes, Iceberg lettuce, Pickled cucumbers, processed cheese, Strips OR",
        ])
        ref.child("food/categoryid-0/burger3").setValue([
            "foodID": "burger3",
            "imageURL": "gs://deliveryfood-db5c8.appspot.com/food/burgers/De Luxe Cheeseburger.png",
            "name": "De Luxe Cheeseburger",
            "price": 2.99,
            "heading1": "Grams / Calories",
            "heading2": "PFC on 100g",
            "heading3": "Delivery in",
            "text1": "203gr / 194kcal",
            "text2": "P: 14.2G F: 6.6G C: 19.4G",
            "text3": "30 min",
            "ingredients": "Bun, Chicken fillet original, Tomatoes, Cheese, Lettuce, Кetchup, Mustard sauce, Pickles, Onion",
        ])
        ref.child("food/categoryid-0/burger4").setValue([
            "foodID": "burger4",
            "imageURL": "gs://deliveryfood-db5c8.appspot.com/food/burgers/Chickenburger.png",
            "name": "Chickenburger",
            "price": 1.20,
            "heading1": "Grams / Calories",
            "heading2": "PFC on 100g",
            "heading3": "Delivery in",
            "text1": "134gr / 261kcal",
            "text2": "P: 8.3G F: 13.1G C: 27.4G",
            "text3": "30 min",
            "ingredients": "Sunny bun, Original chicken cutlet, Mayonnaise sauce, Iceberg lettuce",
        ])
    }
}
