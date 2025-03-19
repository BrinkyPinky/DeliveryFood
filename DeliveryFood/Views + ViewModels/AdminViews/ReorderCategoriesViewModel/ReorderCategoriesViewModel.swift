//
//  ReorderCategoriesViewModel.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 18.03.2025.
//

import Foundation

final class ReorderCategoriesViewModel: ObservableObject {
    @Published var categories = [CategoryModel]()
    @Published var food = [DetailFoodModel]()
    
    @Published var uncategorizedFood = [DetailFoodModel]()
    
    // error View
    @Published var isErrorShowed = false
    var messageText = ""
    
    func onAppear() {
        loadCategories()
        loadFood()
    }
    
    private func loadFood() {
        FirebaseFirestoreUserManager.shared.getFood { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let success):
                food = success
                fillUncategorizedFood()
            case .failure(let error):
                showErrorWithMessage(error.localizedDescription)
            }
        }
    }
    
    private func loadCategories() {
        FirebaseFirestoreUserManager.shared.getCategories { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let success):
                categories = success.sorted(by: { $0.order < $1.order })
                fillUncategorizedFood()
            case .failure(let failure):
                showErrorWithMessage(failure.localizedDescription)
            }
        }
    }
    
    private func fillUncategorizedFood() {
        guard !food.isEmpty && !categories.isEmpty else { return }
        uncategorizedFood = []
        
        for i in 0..<food.count {
            if !categories.contains(where: { $0.id == food[i].categoryID }) {
                uncategorizedFood.append(food[i])
            }
        }
    }
    
    func showErrorWithMessage(_ message: String) {
        messageText = message
        isErrorShowed = true
    }
    
    func onMove(from source: IndexSet, to destination: Int) {
        categories.move(fromOffsets: source, toOffset: destination)
        uploadReorderOnServer()
    }
    
    private func uploadReorderOnServer() {
        for numberInOrder in 0..<categories.count {
            categories[numberInOrder].order = numberInOrder
        }
        
        FirebaseFirestoreAdminManager.shared.uploadReorderedCategoriesOnServer(categories: categories) { [weak self] result in
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
