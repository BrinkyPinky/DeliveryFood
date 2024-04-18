//
//  BillViewModel.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 31.03.2024.
//

import CoreData
import SwiftUI

final class BillViewModel: ObservableObject {
    //errorView
    @Published var isErrorShowed = false
    var errorMessage = ""
    
    @Published var totalPrice: Double = 0
    @Published var isOrderConfirmViewPresented = false
    
    //Удалить позиции в чеке
    func deleteItem(at offsets: IndexSet) {
        do {
            try BillCoreDataManager.shared.removeBillPosition(at: offsets)
        } catch let error as CoreDataError {
            showError(withMessage: error.localizedDescription)
        } catch {
            showError(withMessage: error.localizedDescription)
        }
    }
    
    //Изменяет количество позиций в чеке
    func changeAmountOfBillPosition(positionModel: PositionForBillModel, toValue newValue: Int) {
        do {
            try BillCoreDataManager.shared.changeAmountOfBillPosition(positionModel: positionModel, toValue: newValue)
            updateTotalPrice()
        } catch let error as CoreDataError {
            showError(withMessage: error.localizedDescription)
        } catch {
            showError(withMessage: error.localizedDescription)
        }
    }
    
    // Действие при нажатии кнопки продолжить заказ
    func continueOrderButtonAction(isCartEmpty: Bool) {
        guard !isCartEmpty else {
            showError(withMessage: "Add something to the cart")
            return
        }
        
        guard FirebaseAuthManager.shared.isUserLoggedIn() else {
            showError(withMessage: "You must be logged in")
            return
        }
        
        isOrderConfirmViewPresented = true
    }
    
    //Обновляет общий счет
    func updateTotalPrice() {
        var totalBill: Double = 0
        BillCoreDataManager.shared.billPositions.forEach( { totalBill += $0.price * Double($0.amount) } )
        self.totalPrice = totalBill
    }
    
    //Показать ошибку
    private func showError(withMessage message: String) {
        errorMessage = message
        isErrorShowed = true
    }
}
