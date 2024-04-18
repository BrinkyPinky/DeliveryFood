//
//  FirebaseDatabaseManager.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 20.01.2024.
//

import Foundation
import FirebaseFirestore

final class FirebaseFirestoreManager {
    static var shared = FirebaseFirestoreManager()
    
    let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    
    // Получить список категорий
    func getCategories(completion: @escaping (Result<[CategoryModel], Error>) -> ()) {
        db.collection("Categories").getDocuments { snapshot, error in
            if error != nil {
                completion(.failure(FirebaseFirestoreError.getDataError))
                
            } else {
                var categoryModels = [CategoryModel]()
                var isSuccessfulProcessed = true
                
                snapshot?.documents.forEach { document in
                    do {
                        categoryModels.append(try document.data(as: CategoryModel.self))
                    } catch {
                        isSuccessfulProcessed = false
                    }
                }
                
                if !isSuccessfulProcessed {
                    completion(.failure(FirebaseFirestoreError.dataProcessingError))
                } else {
                    completion(.success(categoryModels))
                }
            }
        }
    }
    
    // Получить список блюд по ID категории
    func getFoodByCategoryId(_ id: Int, completion: @escaping (Result<[DetailFoodModel], Error>) -> ()) {
        db.collection("Food").document("CategoryID-\(id)").collection("Food").getDocuments { snapshot, error in
            if error != nil {
                completion(.failure(FirebaseFirestoreError.getDataError))
                
            } else {
                var detailFoodModels = [DetailFoodModel]()
                var isSuccessfulProcessed = true
                
                snapshot?.documents.forEach { document in
                    do {
                        detailFoodModels.append(try document.data(as: DetailFoodModel.self))
                    } catch {
                        print(error)
                        isSuccessfulProcessed = false
                    }
                }
                
                if !isSuccessfulProcessed {
                    completion(.failure(FirebaseFirestoreError.dataProcessingError))
                } else {
                    completion(.success(detailFoodModels))
                }
            }
        }
    }
    
    // Получить все позиции из чека
    func getAllBillPositions(cartPositions positions: [PositionForBillModel],
        completion: @escaping (Result<[DetailFoodModel], Error>) -> ()) {
        
        db.runTransaction { (transaction, errorPointer) -> Any? in
            let db = Firestore.firestore()
            let references = positions.map { $0.referenceForItself }
            var fetchedFoodModels = [DetailFoodModel]()
            
            references.forEach { reference in
                do {
                    let foodModel = try transaction.getDocument(db.document(reference)).data(as: DetailFoodModel.self)
                    fetchedFoodModels.append(foodModel)
                    
                } catch {
                    errorPointer?.pointee = FirebaseFirestoreError.getDataError as NSError
                    
                }
            }
            
            return fetchedFoodModels
            
        } completion: { object, error in
            if let error = error {
                completion(.failure(error))
                
            } else {
                guard let foodModels = object as? [DetailFoodModel] else {
                    completion(.failure(FirebaseFirestoreError.dataProcessingError))
                    return
                }
                
                completion(.success(foodModels))
                
            }
        }
    }
    
    // Создать нового пользователя
    func createNewUser(name: String, email: String, phoneNumber: String, userID: String, completion: @escaping (Result<Any?, Error>) -> ()) {
        
        db.collection("Users").document(userID).setData([
            "name":name,
            "email":email,
            "phoneNumber":phoneNumber
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(nil))
            }
        }
    }
    
    // Изменить данные о пользователе
    func changeUserData(userID: String, name: String, phoneNumber: String, completion: @escaping (Result<Any?, Error>) -> ()) {
        db.collection("Users").document(userID).updateData([
            "name":name,
            "phoneNumber":phoneNumber
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(nil))
            }
        }
    }
    
    // Добавляет заказ в базу данных
    func placeAnOrder(userID: String, paymentType: String, date: Date, address: AddressModel, totalPrice: Double, cartPositions: [PositionForBillModel], completion: @escaping (Result<Any?, Error>) -> ()) {
        let positions: [[String:Any]] = cartPositions.map({ [
            "foodName": $0.foodName,
            "amount": $0.amount,
            "foodID": $0.foodID,
            "price": $0.price,
            "referenceForItself": $0.referenceForItself
        ] })
        
        let orderData: [String:Any] = [
            "date":date,
            "paymentType":paymentType,
            "address":"\(address.addressDescription), \(address.addressName)",
            "entranceway":address.entranceway ?? "",
            "intercom":address.intercomNumber ?? "",
            "floor":address.floor ?? "",
            "apartment":address.apartment ?? "",
            "orderComment":address.orderComment ?? "",
            "latitude":address.latitude,
            "longtitude":address.longtitude,
            "totalPrice":totalPrice,
            "positions":positions,
            "orderStatus":0
        ]
        
        db.collection("Orders").document(userID).collection("Orders").addDocument(data: orderData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(nil))
            }
        }
    }
    
    // Получить предыдущие заказы пользователя
    func getPreviousOrdersForUserID(_ userID: String, completion: @escaping (Result<[PreviousOrderModel], Error>) -> ()) {
        listener = db.collection("Orders").document(userID).collection("Orders").order(by: "__name__", descending: true).addSnapshotListener({ snapshot, error in
            if error != nil {
                completion(.failure(FirebaseFirestoreError.getDataError))
            }
            
            if let snapshot = snapshot {
                var previousOrderModels = [PreviousOrderModel]()
                
                snapshot.documents.forEach({
                    if let previousOrderModel = try? $0.data(as: PreviousOrderModel.self) {
                        previousOrderModels.append(previousOrderModel)
                    }
                })
                
                if !previousOrderModels.isEmpty {
                    completion(.success(previousOrderModels))
                }
            }
        })
    }
    
    func removeAllListeners() {
        listener?.remove()
    }
    
    // Получить данные пользователя (имя, телефон)
    func getUserDataByUserID(_ userID: String, completion: @escaping (Result<UserDataModel,Error>) -> ()) {
        db.collection("Users").document(userID).getDocument { snapshot, error in
            if error != nil {
                completion(.failure(FirebaseFirestoreError.getDataError))
            }
            
            if let snapshot = snapshot {
                do {
                    let userData = try snapshot.data(as: UserDataModel.self)
                    completion(.success(userData))
                } catch {
                    completion(.failure(FirebaseFirestoreError.dataProcessingError))
                }
            }
        }
    }
}
