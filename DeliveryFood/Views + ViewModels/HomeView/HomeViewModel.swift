//
//  HomeViewModel.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 20.01.2024.
//

import CoreData

final class HomeViewModel: ObservableObject {
    @Published var categories = [CategoryModel]()
    @Published var pickedCategoryID = 0
    @Published var featuredFood = [DetailFoodModel]()
    
    //errorView
    var errorMessage = ""
    @Published var isErrorShowed = false
    
    //loadingStatus
    var isCategoriesLoading = true
    var isFeaturedFoodLoading = true
    
    func onAppearAction() {
        FirebaseDatabaseManager.shared.getCategories { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let categories):
                self.categories = categories
                self.isCategoriesLoading = false
            case .failure(let error):
                if let error = error as? FirebaseDatabaseError {
                    self.showError(withMessage: error.localizedDescription)
                } else {
                    self.showError(withMessage: error.localizedDescription)
                }
            }
        }
        
        FirebaseDatabaseManager.shared.getFoodByCategoryId(pickedCategoryID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let featuredFood):
                self.featuredFood = featuredFood
                self.isFeaturedFoodLoading = false
            case .failure(let error):
                if let error = error as? FirebaseDatabaseError {
                    self.showError(withMessage: error.localizedDescription)
                } else {
                    self.showError(withMessage: error.localizedDescription)
                }
            }
        }
    }
    
    func showError(withMessage message: String) {
        errorMessage = message
        isErrorShowed = true
    }
}
