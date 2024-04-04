//
//  FirebaseDatabaseManager.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 20.01.2024.
//

import Foundation
import FirebaseDatabase

final class FirebaseDatabaseManager {
    static var shared = FirebaseDatabaseManager()
    
    var ref = Database.database().reference()
    
    
    // MARK: Получить список категорий
    func getCategories(completion: @escaping (Result<[CategoryModel], Error>) -> Void) {
        ref.child("categories").observeSingleEvent(of: .value) { dataSnapshot in
            guard dataSnapshot.exists() else {
                completion(.failure(FirebaseDatabaseError.dataIsNotExistError))
                return
            }
            
            guard let data = dataSnapshot.value as? [String:[String:Any]] else {
                completion(.failure(FirebaseDatabaseError.unwrapError))
                return
            }
            
            var categories = [CategoryModel]()
            
            data.forEach({
                guard let id = $0.value["id"] as? Int,
                      let url = $0.value["url"] as? String,
                      let name = $0.value["name"] as? String else {
                    completion(.failure(FirebaseDatabaseError.unwrapError))
                    return
                }
                
                categories.append(CategoryModel(id: id, url: url, name: name))
            })
            
            completion(.success(categories.sorted(by: { $0.id < $1.id })))
        }
    }
    
    // MARK: Получить список блюд по ID категории
    func getFoodByCategoryId(_ id: Int, completion: @escaping (Result<[DetailFoodModel], Error>) -> Void) {
        ref.child("food/categoryid-\(id)").observeSingleEvent(of: .value) { dataSnapshot in
            guard dataSnapshot.exists() else {
                completion(.failure(FirebaseDatabaseError.dataIsNotExistError))
                return
            }
            
            guard let data = dataSnapshot.value as? [String:[String:Any]] else {
                completion(.failure(FirebaseDatabaseError.unwrapError))
                return
            }
            
            var foods = [DetailFoodModel]()
            
            data.forEach {
                guard let ingredients = $0.value["ingredients"] as? String,
                      let heading1 = $0.value["heading1"] as? String,
                      let heading2 = $0.value["heading2"] as? String,
                      let heading3 = $0.value["heading3"] as? String,
                      let text1 = $0.value["text1"] as? String,
                      let text2 = $0.value["text2"] as? String,
                      let text3 = $0.value["text3"] as? String,
                      let imageURL = $0.value["imageURL"] as? String,
                      let name = $0.value["name"] as? String,
                      let price = $0.value["price"] as? Double,
                      let foodID = $0.value["foodID"] as? String else {
                    completion(.failure(FirebaseDatabaseError.unwrapError))
                    return
                }
                
                foods.append(DetailFoodModel(
                    heading1: heading1,
                    heading2: heading2,
                    heading3: heading3,
                    text1: text1,
                    text2: text2,
                    text3: text3,
                    imageURL: imageURL,
                    ingredients: ingredients.components(separatedBy: ", "),
                    name: name,
                    price: price,
                    foodID: foodID
                ))
            }
            
            completion(.success(foods.sorted(by: { $0.foodID < $1.foodID })))
        }
    }
    
//    func fillFoodInCategories() {
//        ref.child("food/categoryid-0/burger0").setValue([
//            "foodID": "burger0",
//            "imageURL": "gs://deliveryfood-db5c8.appspot.com/food/burgers/Chefburger Junior.png",
//            "name": "Chefburger Junior",
//            "price": 2.10,
//            "heading1": "Grams / Calories",
//            "heading2": "PFC on 100g",
//            "heading3": "Delivery in",
//            "text1": "171gr / 219kcal",
//            "text2": "P: 12.6G F: 8.9G C: 22.2G",
//            "text3": "30 min",
//            "ingredients": "Bun with sesame, Strips OR, Caesar sauce, Tomatoes, lettuce",
//        ])
//        ref.child("food/categoryid-0/burger1").setValue([
//            "foodID": "burger1",
//            "imageURL": "gs://deliveryfood-db5c8.appspot.com/food/burgers/Longer Special.png",
//            "name": "Longer Special",
//            "price": 1.40,
//            "heading1": "Grams / Calories",
//            "heading2": "PFC on 100g",
//            "heading3": "Delivery in",
//            "text1": "101gr / 229kcal",
//            "text2": "P: 10.7G F: 9.2G C: 25.8G",
//            "text3": "30 min",
//            "ingredients": "Danish Hot Dog Bun, Bites, Mayo sauce, Mustard sauce, Pickles, Onion",
//        ])
//        ref.child("food/categoryid-0/burger2").setValue([
//            "foodID": "burger2",
//            "imageURL": "gs://deliveryfood-db5c8.appspot.com/food/burgers/Big Maestro.png",
//            "name": "Big Maestro",
//            "price": 4.50,
//            "heading1": "Grams / Calories",
//            "heading2": "PFC on 100g",
//            "heading3": "Delivery in",
//            "text1": "277gr / 232kcal",
//            "text2": "P: 12.8G F: 10.1G C: 22.5G",
//            "text3": "30 min",
//            "ingredients": "Brioche bun, Classic Burger sauce, Fresh tomatoes, Iceberg lettuce, Pickled cucumbers, processed cheese, Strips OR",
//        ])
//        ref.child("food/categoryid-0/burger3").setValue([
//            "foodID": "burger3",
//            "imageURL": "gs://deliveryfood-db5c8.appspot.com/food/burgers/De Luxe Cheeseburger.png",
//            "name": "De Luxe Cheeseburger",
//            "price": 2.99,
//            "heading1": "Grams / Calories",
//            "heading2": "PFC on 100g",
//            "heading3": "Delivery in",
//            "text1": "203gr / 194kcal",
//            "text2": "P: 14.2G F: 6.6G C: 19.4G",
//            "text3": "30 min",
//            "ingredients": "Bun, Chicken fillet original, Tomatoes, Cheese, Lettuce, Кetchup, Mustard sauce, Pickles, Onion",
//        ])
//        ref.child("food/categoryid-0/burger4").setValue([
//            "foodID": "burger4",
//            "imageURL": "gs://deliveryfood-db5c8.appspot.com/food/burgers/Chickenburger.png",
//            "name": "Chickenburger",
//            "price": 1.20,
//            "heading1": "Grams / Calories",
//            "heading2": "PFC on 100g",
//            "heading3": "Delivery in",
//            "text1": "134gr / 261kcal",
//            "text2": "P: 8.3G F: 13.1G C: 27.4G",
//            "text3": "30 min",
//            "ingredients": "Sunny bun, Original chicken cutlet, Mayonnaise sauce, Iceberg lettuce",
//        ])
//    }
}
