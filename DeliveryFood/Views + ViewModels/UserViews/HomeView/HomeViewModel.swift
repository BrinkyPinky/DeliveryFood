//
//  HomeViewModel.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 20.01.2024.
//

import CoreData

final class HomeViewModel: ObservableObject {
    @Published var categories = [CategoryModel]()
    @Published var pickedCategoryID = ""
    
    // foods by pickedCategory
    @Published var featuredFood = [DetailFoodModel]()
    
    // all foods
    private var foodList = [DetailFoodModel]()
    
    //errorView
    var errorMessage = ""
    @Published var isErrorShowed = false
    
    //loadingStatus
    var isCategoriesLoading = true
    var isFeaturedFoodLoading = true
    
    func onAppearAction() {
        loadCategories()
        loadFood()
    }
    
    func loadCategories() {
        FirebaseFirestoreUserManager.shared.getCategories { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let categories):
                let categories = categories.sorted(by: { $0.order < $1.order })
                self.categories = categories
                self.isCategoriesLoading = false
                
                guard let firstCategory = categories.first else { return }
                pickedCategoryID = firstCategory.id
                
                // Если список еды загрузился первее, то загружаем еду по первой категории
                guard !foodList.isEmpty else { return }
                loadFeaturedFood()
                
            case .failure(let error):
                self.showError(withMessage: error.localizedDescription)
            }
        }
    }
    
    func loadFood() {
        FirebaseFirestoreUserManager.shared.getFood { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let success):
                self.foodList = success
                self.isFeaturedFoodLoading = false
                
                // Если список еды
                guard !categories.isEmpty else { return }
                loadFeaturedFood()
                
            case .failure(let failure):
                self.showError(withMessage: failure.localizedDescription)
            }
        }
    }
    
    func loadFeaturedFood() {
        featuredFood = []
        featuredFood = foodList.filter({ $0.categoryID == pickedCategoryID }).sorted(by: { $0.orderInCategory < $1.orderInCategory })
    }
    
    func showError(withMessage message: String) {
        errorMessage = message
        isErrorShowed = true
    }
}
