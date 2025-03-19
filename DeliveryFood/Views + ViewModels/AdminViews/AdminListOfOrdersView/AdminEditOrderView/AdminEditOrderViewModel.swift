//
//  AdminEditOrderViewModel.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 13.03.2025.
//

import Foundation

final class AdminEditOrderViewModel: ObservableObject {
    @Published var currentItemPickedID: Int = 0
    @Published var isDraggingOrderStatus = false
    @Published var orderStatusItemHeight: CGFloat = 0
    
    @Published var clientsDetails = ClientDetailsModel.loadingData
    let order: AdminOrderModel
    
    // Is On Live
    @Published var isOnLiveStatus = true
    
    // ErrorView
    @Published var isErrorShowed = false
    var errorMessage = ""
    
    init(orderModel: AdminOrderModel) {
        self.order = orderModel
        self.currentItemPickedID = orderModel.orderStatus
    }
    
    func onAppearAction() {
        loadClientDetails(userID: order.userID)
    }
    
    private func showError(message: String) {
        errorMessage = message
        isErrorShowed = true
    }
    
    private func loadClientDetails(userID: String) {
        FirebaseFirestoreAdminManager.shared.getUserInfo(userID: userID) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let success):
                clientsDetails = success
            case .failure(let failure):
                showError(message: failure.localizedDescription)
            }
        }
    }
    
    func onDragEnd() {
        isDraggingOrderStatus = false
        isOnLiveStatus = false
        
        FirebaseFirestoreAdminManager.shared.changeOrderStatusForOrder(order, toStatus: currentItemPickedID) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(_):
                isOnLiveStatus = true
            case .failure(let failure):
                showError(message: failure.localizedDescription)
            }
        }
    }
    
    func orderStatusDragged(location: CGPoint) {
        var pickedID = Int(Double(location.y/orderStatusItemHeight).rounded(.down) - 1)
        
        if pickedID > 4 {
            pickedID = 4
        } else if pickedID < -1 {
            pickedID = -1
        }
        
        if currentItemPickedID != pickedID {
            HapticsManager.shared.selection()
        }
        
        currentItemPickedID = pickedID
    }
}
