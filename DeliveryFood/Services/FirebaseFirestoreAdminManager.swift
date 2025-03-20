//
//  FirebaseFirestoreAdminManager.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 14.03.2025.
//

import FirebaseFirestore
import Foundation
import UIKit.UIImage

final class FirebaseFirestoreAdminManager: ObservableObject {
    static let shared = FirebaseFirestoreAdminManager()

    private let db = Firestore.firestore()
    private var ordersListener: ListenerRegistration?

    @Published var isAdmin = false

    func checkIfUserIsAdmin(userID: String) {
        db.collection("ListOfUsersWithRights").document("List").getDocument {
            [weak self] snapshot, error in
            guard let self = self else { return }
            guard let data = snapshot?.data() as? [String: [String]] else {
                return
            }
            if let adminData = data["admin"] {
                isAdmin = adminData.contains(userID)
            }
        }
    }

    func notAdminAnymore() {
        isAdmin = false
    }

    func removeListeners() {
        ordersListener?.remove()
    }

    func uploadReorderedCategoriesOnServer(
        categories: [CategoryModel],
        completion: @escaping (Result<Any?, Error>) -> Void
    ) {
        db.runTransaction { [unowned self] transaction, _ in
            categories.forEach { categoryModel in

                do {
                    let data = try JSONEncoder().encode(categoryModel)
                    let jsonData = try JSONSerialization.jsonObject(with: data)

                    guard let jsonData = jsonData as? [String: Any] else {
                        return
                    }

                    transaction.setData(
                        jsonData,
                        forDocument: db.document(
                            "Categories/\(categoryModel.id)"))
                } catch {
                    completion(.failure(AdminError.uploadOnServerError))
                }
            }

            return nil
        } completion: { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(nil))
            }
        }
    }

    func uploadReorderedFoodOnServer(
        food: [DetailFoodModel],
        completion: @escaping (Result<Any?, Error>) -> Void
    ) {
        db.runTransaction { [unowned self] transaction, _ in
            food.forEach { foodModel in

                do {
                    let data = try JSONEncoder().encode(foodModel)
                    let jsonData = try JSONSerialization.jsonObject(with: data)

                    guard let jsonData = jsonData as? [String: Any] else {
                        return
                    }

                    transaction.setData(
                        jsonData,
                        forDocument: db.document("Food/\(foodModel.foodID)"))
                } catch {
                    completion(.failure(AdminError.uploadOnServerError))
                }
            }

            return nil
        } completion: { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(nil))
            }
        }
    }

    func uploadOrUpdateFoodModel(
        foodModel: DetailFoodModel, image: UIImage, isNeedToUploadPhoto: Bool,
        completion: @escaping (Result<Any?, Error>) -> Void
    ) {
        var foodModel = foodModel

        if foodModel.foodID.isEmpty {
            foodModel.foodID = db.collection("food").document().documentID
        }

        let imagePath = "food/\(foodModel.foodID)"

        do {
            let jsonData = try JSONEncoder().encode(foodModel)
            let data =
                try JSONSerialization.jsonObject(with: jsonData)
                as? [String: Any]

            guard let data = data else {
                completion(.failure(AdminError.JSONEncoderError))
                return
            }

            db.document("Food/\(foodModel.foodID)").setData(data) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    guard isNeedToUploadPhoto else {
                        completion(.success(nil))
                        return
                    }
                    FirebaseStorageManager.shared.uploadImage(
                        withPath: imagePath, image: image
                    ) { [unowned self] result in
                        switch result {
                        case .success(_):
                            completion(.success(nil))
                        case .failure(let failure):
                            completion(.failure(failure))
                            db.document("Food/\(foodModel.foodID)").delete()
                        }
                    }
                }
            }
        } catch {
            completion(.failure(AdminError.JSONEncoderError))
        }
    }

    enum typeToRemove {
        case category, food
    }

    func removeCategoryOrFood(
        typeToRemove: typeToRemove, id: String,
        completion: @escaping (Result<Any?, Error>) -> Void
    ) {
        var imagePath = ""
        var docPath = ""

        switch typeToRemove {
        case .category:
            docPath = "Categories/\(id)"
            imagePath = "categories/\(id)"
        case .food:
            docPath = "Food/\(id)"
            imagePath = "food/\(id)"
        }

        db.document(docPath).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                FirebaseStorageManager.shared.removeImage(withPath: imagePath) {
                    result in
                    switch result {
                    case .success(_):
                        completion(.success(nil))
                    case .failure(let failure):
                        completion(.failure(failure))
                    }
                }
            }
        }
    }

    func uploadNewOrChangeExistingCategory(
        category: CategoryModel, image: UIImage, isNeedToUploadPhoto: Bool,
        completion: @escaping (Result<Any?, Error>) -> Void
    ) {
        var category = category

        if category.id.isEmpty {
            category.id = db.collection("categories").document().documentID
        }

        let imagePath = "categories/\(category.id)"

        do {
            let jsonData = try JSONEncoder().encode(category)
            let data =
                try JSONSerialization.jsonObject(with: jsonData)
                as? [String: Any]

            guard let data = data else {
                completion(.failure(AdminError.JSONEncoderError))
                return
            }

            // Записываем новую категорию в FireStore
            db.document("Categories/\(category.id)").setData(data) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    guard isNeedToUploadPhoto else {
                        completion(.success(nil))
                        return
                    }

                    // Загружаем фотографию
                    FirebaseStorageManager.shared.uploadImage(
                        withPath: imagePath, image: image
                    ) { [unowned self] result in
                        switch result {
                        case .success(_):
                            completion(.success(nil))
                        case .failure(let error):
                            completion(.failure(error))
                            db.document("Categories/\(category.id)").delete()
                        }
                    }
                }
            }
        } catch {
            completion(.failure(AdminError.JSONEncoderError))
        }
    }

    func changeOrderStatusForOrder(
        _ order: AdminOrderModel, toStatus newStatus: Int,
        completion: @escaping (Result<Any?, Error>) -> Void
    ) {
        db.runTransaction { [unowned self] transaction, errorPointer in
            transaction.updateData(
                ["orderStatus": newStatus],
                forDocument: db.document(order.ordersByDatesRef))
            transaction.updateData(
                ["orderStatus": newStatus],
                forDocument: db.document(order.ordersByUsersRef))

            return nil
        } completion: { _, error in
            if error != nil {
                completion(.failure(AdminError.updateNewOrderStatusError))
            } else {
                completion(.success(nil))
            }
        }

    }

    func getOrders(
        for date: String,
        completion: @escaping (Result<[AdminOrderModel], Error>) -> Void
    ) {
        ordersListener?.remove()

        ordersListener = db.collection("Orders").document("OrdersByDates")
            .collection(date).addSnapshotListener { snapshot, error in
                if let error = error {
                    completion(Result.failure(error))
                    return
                }

                guard let snapshot = snapshot else { return }

                var orders = [AdminOrderModel]()

                snapshot.documents.forEach { documentSnapshot in
                    do {
                        orders.append(
                            try documentSnapshot.data(as: AdminOrderModel.self))
                    } catch {
                        completion(Result.failure(error))
                    }
                }

                completion(Result.success(orders))
            }
    }

    func getUserInfo(
        userID: String,
        completion: @escaping (Result<ClientDetailsModel, Error>) -> Void
    ) {
        db.collection("Users").document(userID).getDocument(
            as: ClientDetailsModel.self
        ) { result in
            switch result {
            case .success(let success):
                completion(.success(success))
            case .failure(_):
                completion(.failure(AdminError.getUserDataError))
            }
        }
    }
}
