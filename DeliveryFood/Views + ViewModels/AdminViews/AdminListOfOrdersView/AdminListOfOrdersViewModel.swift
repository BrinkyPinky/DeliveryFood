//
//  AdminListOfOrdersViewModel.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 14.03.2025.
//

import Foundation

final class AdminListOfOrdersViewModel: ObservableObject {
    @Published var currentPickedDate = Date()
    @Published var isDatePickerShowed = false
    
    @Published var orders = [AdminOrderModel]()
    
    @Published var completedOrders = [AdminOrderModel]()
    
    // Orders loading status
    @Published var areOrdersLoading = true
    
    // ErrorView
    @Published var isErrorShowed = false
    var errorText = ""
    
    deinit {
        FirebaseFirestoreAdminManager.shared.removeListeners()
    }
    
    func showErrorWithMessage(_ message: String) {
        errorText = message
        isErrorShowed = true
    }

    func loadOrders() {
        areOrdersLoading = true
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        FirebaseFirestoreAdminManager.shared.getOrders(for: dateFormatter.string(from: currentPickedDate)) { [weak self] result in
            guard let self = self else { return }
            switch(result) {
            case .success(let orders):
                let orders = orders.sorted(by: {$0.date < $1.date})
                
                self.orders = []
                self.completedOrders = []
                
                orders.forEach { model in
                    if (model.orderStatus == -1 || model.orderStatus == 4) {
                        self.completedOrders.append(model)
                    } else {
                        self.orders.append(model)
                    }
                }
                
                areOrdersLoading = false
            case .failure(let error):
                showErrorWithMessage(error.localizedDescription)
                areOrdersLoading = false
            }
        }
    }
    
    func onAppearAction() {
        loadOrders()
    }
}
