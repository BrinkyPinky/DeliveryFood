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
    
    //Удалить позиции в чеке
    func deleteItem(at offsets: IndexSet) {
        do {
            try CoreDataManager.shared.removeBillPosition(at: offsets)
        } catch let error as CoreDataError {
            showError(withMessage: error.localizedDescription)
        } catch {
            showError(withMessage: error.localizedDescription)
        }
    }
    
    func changeAmountOfBillPosition(positionModel: PositionForBillModel, toValue newValue: Int) {
        do {
            try CoreDataManager.shared.changeAmountOfBillPosition(positionModel: positionModel, toValue: newValue)
        } catch let error as CoreDataError {
            showError(withMessage: error.localizedDescription)
        } catch {
            showError(withMessage: error.localizedDescription)
        }
    }
    
    //Показать ошибку
    private func showError(withMessage message: String) {
        errorMessage = message
        isErrorShowed = true
    }
}
