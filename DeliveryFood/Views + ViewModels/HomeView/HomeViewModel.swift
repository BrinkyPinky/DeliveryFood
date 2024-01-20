//
//  HomeViewModel.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 20.01.2024.
//

import Foundation

class HomeViewModel: ObservableObject {
    @Published var categories = [CategoryModel]()
    
    @Published var pickedCategoryID = 0
    
    func onAppearAction() {
        FirebaseDatabaseManager.shared.getCategories { categories in
            self.categories = categories
        } completionError: { error in
            // MARK: HANDLE ERROR
        }

    }
}
