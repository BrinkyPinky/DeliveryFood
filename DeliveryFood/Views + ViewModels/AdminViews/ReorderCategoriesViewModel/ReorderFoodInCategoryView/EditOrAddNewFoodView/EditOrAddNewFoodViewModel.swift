//
//  EditOrAddNewFoodViewModel.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 19.03.2025.
//

import Foundation
import UIKit.UIImage

final class EditOrAddNewFoodViewModel: ObservableObject {
    @Published var image = UIImage()
    @Published var isImagePickerPresented = false

    @Published var isDataUploading = false

    @Published var isPreviewDetailFoodViewPresented = false

    var foodModelForPreview: DetailFoodModel {
        return DetailFoodModel(
            heading1: heading1, heading2: heading2, heading3: heading3,
            text1: text1, text2: text2, text3: text3,
            categoryID: pickedCategory, orderInCategory: 0,
            ingredients: ingredients, name: name, price: price, foodID: "")
    }

    var foodModel: DetailFoodModel

    // For ordering
    var allCategories = [CategoryModel]()
    var allFoods = [DetailFoodModel]()
    var currentCategory: CategoryModel

    private var dismiss: (() -> Void)?

    // Food Details
    @Published var name = ""
    @Published var heading1 = ""
    @Published var heading2 = ""
    @Published var heading3 = ""
    @Published var text1 = ""
    @Published var text2 = ""
    @Published var text3 = ""
    @Published var price: Double = 0
    @Published var ingredients = [String]()
    @Published var pickedCategory: String = ""

    // Error View
    @Published var isErrorShowed = false
    var errorMessage = ""

    // Deletion alert
    @Published var isDeletionAlertShown = false

    init(foodModel: DetailFoodModel, currentCategory: CategoryModel) {
        self.foodModel = foodModel
        self.pickedCategory = currentCategory.id
        self.currentCategory = currentCategory

        name = foodModel.name
        heading1 = foodModel.heading1
        heading2 = foodModel.heading2
        heading3 = foodModel.heading3
        text1 = foodModel.text1
        text2 = foodModel.text2
        text3 = foodModel.text3
        price = foodModel.price
        ingredients = foodModel.ingredients
        pickedCategory = currentCategory.id
    }

    init(order: Int, currentCategory: CategoryModel) {
        self.foodModel = DetailFoodModel(
            heading1: "", heading2: "", heading3: "", text1: "", text2: "",
            text3: "", categoryID: "", orderInCategory: order, ingredients: [],
            name: "", price: 0, foodID: "")
        self.pickedCategory = currentCategory.id
        self.currentCategory = currentCategory
    }

    func onAppear(allCategories: [CategoryModel], allFoods: [DetailFoodModel]) {
        self.allCategories = allCategories
        self.allFoods = allFoods

        guard !foodModel.foodID.isEmpty else { return }
        FirebaseStorageManager.shared.downloadImage(
            withPath: "food/\(foodModel.foodID)"
        ) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let success):
                guard let image = UIImage(data: success) else {
                    showErrorWithMessage(
                        AdminError.imageConvertError.localizedDescription)
                    return
                }
                self.image = image
            case .failure(let failure):
                showErrorWithMessage(failure.localizedDescription)
            }
        }
    }

    func setDismissAction(_ dismiss: @escaping () -> Void) {
        self.dismiss = dismiss
    }

    func addNewIngredient() {
        ingredients.append("")
    }

    func deleteFood() {
        guard !foodModel.foodID.isEmpty, !isDataUploading else { return }
        isDataUploading = true
        FirebaseFirestoreAdminManager.shared.removeCategoryOrFood(
            typeToRemove: .food, id: foodModel.foodID
        ) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(_):
                dismiss?()
                isDataUploading = false
            case .failure(let failure):
                showErrorWithMessage(failure.localizedDescription)
                isDataUploading = false
            }
        }
    }

    func uploadFoodOnServer() {
        guard !isDataUploading else { return }
        isDataUploading = true

        guard let pngData = image.pngData() else {
            showErrorWithMessage(
                AdminError.imageConvertError.localizedDescription)
            isDataUploading = false
            return
        }

        foodModel.heading1 = heading1
        foodModel.heading2 = heading2
        foodModel.heading3 = heading3
        foodModel.text1 = text1
        foodModel.text2 = text2
        foodModel.text3 = text3
        foodModel.ingredients = ingredients
        foodModel.name = name
        foodModel.price = price
        foodModel.categoryID = pickedCategory

        FirebaseFirestoreAdminManager.shared.uploadOrUpdate(
            foodModel: foodModel, imageData: pngData
        ) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(_):
                dismiss?()
                isDataUploading = false
            case .failure(let failure):
                showErrorWithMessage(failure.localizedDescription)
                isDataUploading = false
            }
        }
    }

    private func showErrorWithMessage(_ message: String) {
        errorMessage = message
        isErrorShowed = true
    }
}
