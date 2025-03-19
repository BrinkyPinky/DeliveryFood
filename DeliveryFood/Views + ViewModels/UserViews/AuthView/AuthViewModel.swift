//
//  AuthViewModel.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 13.04.2024.
//

import Foundation

enum AuthOption {
    case authorization, registration, forgotThePassword, notDeterminated
}

final class AuthViewModel: ObservableObject {
    // Опции входа (Регистрация, авторизация, забыл пароль)
    var authState: AuthOption = .notDeterminated
    
    // Wave Shape Animation Value
    @Published var waveShapeLeftY: Double = 0
    @Published var waveShapeRightY: Double = 0
    @Published var waveShapeControlY: Double = 0
    
    // Wave Shape Background Animation Value
    @Published var waveShapeBackgroundLeftY: Double = 0
    @Published var waveShapeBackgroundRightY: Double = 0
    @Published var waveShapeBackgroundControlY: Double = 0
    
    // Height Of View
    var viewHeight: Double = 0
    
    // Следует ли View показывать Login/Register/ForgotThePassword Views
    @Published var isViewShouldDisplayingAuthStateViews = false
    
    // Тексты для TextFields
    @Published var nameText = ""
    @Published var passwordText = ""
    @Published var emailText = ""
    @Published var phoneNumberText = "+7"
    
    // Происходит ли обработка регистрации/входа
    @Published var isAuthActionLoading = false
    
    // Error View
    @Published var isErrorShowed = false
    var errorMessage = ""
    
    // MARK: Login/Register/ForgotThePassword Actions
    
    func registerAction(completionSuccess: @escaping () -> ()) {
        guard phoneNumberText.isPhoneNumberValid() else {
            showErrorWithMessage(AuthError.invalidPhoneNumber.localizedDescription)
            return
        }
        
        guard !nameText.isEmpty else {
            showErrorWithMessage(AuthError.nameIsEmpty.localizedDescription)
            return
        }
        
        isAuthActionLoading = true
        
        // Создаем нового пользователя
        FirebaseAuthManager.shared.registerNewUser(withEmail: emailText, password: passwordText) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let userID):
                
                // Добавляем данные пользователя в базу данных 
                FirebaseFirestoreUserManager.shared.createNewUser(
                    name: nameText,
                    email: emailText,
                    phoneNumber: phoneNumberText,
                    userID: userID
                ) { result in
                    
                    switch result {
                    case .success(_):
                        self.isAuthActionLoading = false
                        completionSuccess()
                        
                    case .failure(let error):
                        // Удаляем аккаунт если не получилось добавить пользователя в базу данных
                        FirebaseAuthManager.shared.deleteAccount()
                        self.showErrorWithMessage(error.localizedDescription)
                        self.isAuthActionLoading = false
                    }
                }
            case .failure(let error):
                self.showErrorWithMessage(error.localizedDescription)
                self.isAuthActionLoading = false
            }
        }
    }
    
    func loginAction(completionSuccess: @escaping () -> ()) {
        isAuthActionLoading = true
        
        FirebaseAuthManager.shared.login(withEmail: emailText, password: passwordText) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(_):
                isAuthActionLoading = false
                completionSuccess()
                
            case .failure(let error):
                showErrorWithMessage(error.localizedDescription)
                isAuthActionLoading = false
            }
        }
    }
    
    func forgotThePasswordAction(completionSuccess: @escaping () -> ()) {
        isAuthActionLoading = true
        
        FirebaseAuthManager.shared.restorePassword(withEmail: emailText) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(_):
                completionSuccess()
                isAuthActionLoading = false
            case .failure(let error):
                showErrorWithMessage(error.localizedDescription)
                isAuthActionLoading = false
            }
        }
    }
    
    // MARK: Error Handling
    
    // Показать ошибку
    func showErrorWithMessage(_ message: String) {
        errorMessage = message
        isErrorShowed = true
    }
    
    // MARK: WaveShapes Animation
    
    // Reset Shape To Default Position
    func resetShapes() {
        isViewShouldDisplayingAuthStateViews = false
        waveShapeLeftY = viewHeight/1.25
        waveShapeRightY = viewHeight/1.3
        waveShapeControlY = viewHeight/1.45
        
        waveShapeBackgroundLeftY = viewHeight/1.35
        waveShapeBackgroundRightY = viewHeight/1.45
        waveShapeBackgroundControlY = viewHeight/1.20
    }
    
    // Fill the view with waveShapes
    func animateShapes() {
        waveShapeLeftY = -viewHeight/5
        waveShapeRightY = -viewHeight/5
        waveShapeControlY = -viewHeight/20
        
        waveShapeBackgroundLeftY = -viewHeight/2
        waveShapeBackgroundRightY = -viewHeight/3
        waveShapeBackgroundControlY = -viewHeight/1.5
    }
}
