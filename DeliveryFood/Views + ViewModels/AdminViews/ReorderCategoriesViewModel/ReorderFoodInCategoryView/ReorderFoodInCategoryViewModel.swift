//
//  ReorderFoodInCategoryViewModel.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 19.03.2025.
//

import Foundation

final class ReorderFoodInCategoryViewModel: ObservableObject {
    @Published var foodInCategory = [DetailFoodModel]()
    
    @Published var isDeletionAlertShown = false
    
    var dismissAction: (() -> Void)?
    @Published var isDataUploading = false
    
    // Message View
    @Published var isErrorShowed = false
    var errorMessage = ""
    
    func setDismissAction(_ dismiss: @escaping () -> Void) {
        dismissAction = dismiss
    }
    
    func deleteCategory(categoryModel: CategoryModel) {
        guard !categoryModel.id.isEmpty, !isDataUploading else { return }
        isDataUploading = true
        FirebaseFirestoreAdminManager.shared.removeCategoryOrFood(typeToRemove: .category, id: categoryModel.id) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(_):
                dismissAction?()
                isDataUploading = false
            case .failure(let failure):
                showErrorWithMessage(failure.localizedDescription)
                isDataUploading = false
            }
        }
    }
    
    func filterAndSortFoodForCurrentCategory(food: [DetailFoodModel], currentCategory: CategoryModel) {
        foodInCategory = food.filter({ $0.categoryID == currentCategory.id }).sorted(by: { $0.orderInCategory < $1.orderInCategory })
    }
    
    func showErrorWithMessage(_ message: String) {
        errorMessage = message
        isErrorShowed = true
    }
    
    func onMove(from source: IndexSet, to destination: Int) {
        foodInCategory.move(fromOffsets: source, toOffset: destination)
        uploadReorderOnServer()
    }
    
    private func uploadReorderOnServer() {
        for numberInOrder in 0..<foodInCategory.count {
            foodInCategory[numberInOrder].orderInCategory = numberInOrder
        }
        
        FirebaseFirestoreAdminManager.shared.uploadReorderedFoodOnServer(food: foodInCategory) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(_):
                return
            case .failure(let failure):
                showErrorWithMessage(failure.localizedDescription)
            }
        }
    }
}
