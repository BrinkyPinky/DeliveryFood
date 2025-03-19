//
//  AccountViewModel.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 14.04.2024.
//

import Foundation

final class AccountViewModel: ObservableObject {
    // Выбранная настройка в профиле
    // 1 - Заказы; 2 - Адреса; 3 - Настройки
    @Published var currentPickedProfileData: Int = 1
    
    // Error View
    var errorMessage = ""
    @Published var isErrorShowed = false
    
    // Предыдущие заказы
    @Published var previousOrderModels = [PreviousOrderModel]()
    
    // Показывает загрузилась ли информация о пользователе
    @Published var isUserDataLoaded = false
    
    // Показывает нужно ли появиться кнопке для сохранения данных, которые внес пользователь
    @Published var isSaveButtonShouldAppear = false
    
    // Информация о пользователе
    @Published var userName = ""
    @Published var userPhoneNumber = ""
    @Published var userID = "Loading..."
    
    // OnAppearAction
    func onAppearAction() {
        guard let userID = FirebaseAuthManager.shared.getUserID() else {
            showErrorWithMessage(AuthError.failedToGetUserID.localizedDescription)
            return
        }
        
        self.userID = userID
        
        FirebaseFirestoreUserManager.shared.getPreviousOrdersForUserID(userID) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let previousOrderModels):
                self.previousOrderModels = previousOrderModels.sorted(by: { $0.date < $1.date })
                
            case .failure(let error):
                guard let error = error as? FirebaseFirestoreError else {
                    showErrorWithMessage(error.localizedDescription)
                    return
                }
                showErrorWithMessage(error.localizedDescription)
            }
        }
        
        loadUserData()
    }
    
    func reorderButtonAction(orderModel: PreviousOrderModel, completionSuccess: () -> ()) {
        BillCoreDataManager.shared.removeAllBillPositions()
        do {
            try BillCoreDataManager.shared.addBillPositionsFromPreviousOrder(orderModel: orderModel)
            completionSuccess()
        } catch {
            showErrorWithMessage(error.localizedDescription)
        }
    }
    
    // OnDisappearAction
    func onDisappearAction() {
        FirebaseFirestoreUserManager.shared.removeAllListeners()
    }
    
    // Сохранить изменение пользовательских данных
    func saveDataChangesAction() {
        guard !userName.isEmpty, !userPhoneNumber.isEmpty else {
            showErrorWithMessage("Name and Phone Number must be provided")
            return
        }
        
        guard userPhoneNumber.isPhoneNumberValid() else {
            showErrorWithMessage("Phone number is wrong formatted")
            return
        }
        
        guard let userID = FirebaseAuthManager.shared.getUserID() else {
            showErrorWithMessage(AuthError.failedToGetUserID.localizedDescription)
            return
        }
        
        FirebaseFirestoreUserManager.shared.changeUserData(userID: userID, name: userName, phoneNumber: userPhoneNumber) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(_):
                isSaveButtonShouldAppear = false
            case .failure(let error):
                showErrorWithMessage(error.localizedDescription)
            }
        }
    }
    
    // Загрузить данные о пользователе
    func loadUserData() {
        isUserDataLoaded = false
        isSaveButtonShouldAppear = false
        
        guard let userID = FirebaseAuthManager.shared.getUserID() else {
            showErrorWithMessage(AuthError.failedToGetUserID.localizedDescription)
            return
        }
        
        FirebaseFirestoreUserManager.shared.getUserDataByUserID(userID) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let userDataModel):
                self.userName = userDataModel.name
                self.userPhoneNumber = userDataModel.phoneNumber
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self.isUserDataLoaded = true
                }
            case .failure(let error):
                guard let error = error as? FirebaseFirestoreError else {
                    showErrorWithMessage(error.localizedDescription)
                    return
                }
                showErrorWithMessage(error.localizedDescription)
            }
        }
    }
    
    // Действие для выхода из системы
    func logOutAction(completionSuccess: @escaping () -> ()) {
        FirebaseAuthManager.shared.logOut { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(_):
                completionSuccess()
            case .failure(let error):
                showErrorWithMessage(error.localizedDescription)
            }
        }
    }
    
    // Действите при изменении Пользовательских Данных (имени, телефона и др.)
    func userDataHasChangedAction() {
        guard isUserDataLoaded else { return }
        print("\(Date()) Text")
        isSaveButtonShouldAppear = true
    }
    
    // Показать ошибку
    func showErrorWithMessage(_ message: String) {
        errorMessage = message
        isErrorShowed = true
    }
}
