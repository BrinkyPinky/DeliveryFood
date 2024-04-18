//
//  OrderConfirmViewModel.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 05.04.2024.
//

import Foundation

protocol DeliverDetailTypes {}

enum DeliveryTimeType: DeliverDetailTypes {
    case ASAP, onTime
}

enum PaymentType: DeliverDetailTypes {
    case card, cash
    
    var description: String {
        switch self {
        case .card: "By Card"
        case .cash: "By Cash"
        }
    }
}

final class OrderConfirmViewModel: ObservableObject {
    // Сумма заказа
    var totalPrice: Double
    
    // Состояние при котором происходит загрузка и проверка цен
    @Published var isPriceLoading = false
    
    // Details
    @Published var deliveryTimeType = DeliveryTimeType.ASAP
    @Published var selectedDate = Date()
    @Published var paymentType = PaymentType.card
    @Published var pickedAdressTag = 1
    
    // Address
    @Published var currentPickedAddressModel: AddressModel?
    
    // ErrorView
    @Published var isErrorShowed = false
    var errorMessage = ""
    
    // Date Range for DatePicker
    var dateRange: ClosedRange<Date> {
        let currentDate = Date()
        
        if currentDate < Calendar.current.date(bySettingHour: 23, minute: 0, second: 0, of: currentDate)! {
            return Calendar.current.date(byAdding: DateComponents(minute: 30), to: currentDate)!...Calendar.current.date(bySettingHour: 23, minute: 0, second: 0, of: currentDate)!
        }

        return Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: currentDate)!...Calendar.current.date(bySettingHour: 23, minute: 0, second: 0, of: currentDate)!
    }
    
    init(totalPrice: Double) {
        self.totalPrice = totalPrice
    }
    
    func changeDeliverDetailTypes(newType: DeliverDetailTypes) {
        if let newType = newType as? DeliveryTimeType {
            deliveryTimeType = newType
        } else if let newType = newType as? PaymentType {
            paymentType = newType
        }
    }
    
    // OnAppear Action
    func onAppearAction() {
        do {
            guard let lastUsedAdress = try AddressCoreDataManager.shared.getLastUsedAddress() else { return }
            currentPickedAddressModel = lastUsedAdress
        } catch {}
    }
    
    func showErrorWithMessage(_ message: String) {
        errorMessage = message
        isErrorShowed = true
    }
    
    // Действие кнопки сделать заказ
    // Проверяет не изменилась ли сумма на товары в корзине
    func makeOrderAction(completion: @escaping () -> ()) {
        isPriceLoading = true
        
        let cartPositions = BillCoreDataManager.shared.billPositions
        FirebaseFirestoreManager.shared.getAllBillPositions(cartPositions: cartPositions) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let foodModels):
                // Массив сумм за единицу товара (количество * цена)
                var arrayOfPrices = [Double]()
                
                for index in 0..<foodModels.count {
                    arrayOfPrices.append(foodModels[index].price * Double(cartPositions[index].amount))
                }
                
                // Итоговая сумма
                let total = arrayOfPrices.reduce(0, +)
                
                // Если цена сходится то делаем заказ иначе обновляем цены и выдаем ошибку
                guard total == totalPrice else {
                    do {
                        try BillCoreDataManager.shared.updatePrices(foodModels: foodModels)
                        isPriceLoading = false
                        completion()
                    } catch {
                        showErrorWithMessage(error.localizedDescription)
                        isPriceLoading = false
                    }
                    return
                }
                
                guard let userID = FirebaseAuthManager.shared.getUserID() else {
                    showErrorWithMessage(AuthError.failedToGetUserID.localizedDescription)
                    return
                }
                guard let addressModel = currentPickedAddressModel else {
                    showErrorWithMessage("You need to select an address")
                    return
                }
                let date = deliveryTimeType == .ASAP ? Date().advanced(by: 30 * 60) : selectedDate
                
                // Делаем заказ
                FirebaseFirestoreManager.shared.placeAnOrder(
                    userID: userID,
                    paymentType: paymentType.description,
                    date: date,
                    address: addressModel,
                    totalPrice: total,
                    cartPositions: cartPositions) { result in
                        switch result {
                        case .success(_):
                            BillCoreDataManager.shared.removeAllBillPositions()
                            self.isPriceLoading = false
                            completion()
                            
                        case .failure(let error):
                            self.showErrorWithMessage(error.localizedDescription)
                            self.isPriceLoading = false
                        }
                        
                    }
            case .failure(let error):
                showErrorWithMessage(error.localizedDescription)
                isPriceLoading = false
            }
        }
    }
}
