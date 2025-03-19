//
//  FirebaseAuthManager.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 10.04.2024.
//

import FirebaseAuth

final class FirebaseAuthManager {
    static let shared = FirebaseAuthManager()
    
    private let adminManager = FirebaseFirestoreAdminManager.shared
    
    private let auth = Auth.auth()
    
    /// Регистрирует нового пользователя
    /// - Parameters:
    ///   - email: Электронная почта пользователя
    ///   - password: Пароль пользователя
    ///   - completion: Возвращает Result либо ID пользователя либо ошибку
    func registerNewUser(withEmail email: String, password: String, completion: @escaping (Result<String, Error>) -> ()) {
        auth.createUser(withEmail: email, password: password) { data, error in
            if let error = error {
                completion(.failure(error))
            }
            
            if let data = data {
                completion(.success(data.user.uid))
            }
        }
    }
    
    
    /// Авторизует пользователя
    /// - Parameters:
    ///   - email: Электронная почта пользователя
    ///   - password: Пароль пользователя
    ///   - completion: Возвращает Result nil либо ошибку
    func login(withEmail email: String, password: String, completion: @escaping (Result<Any?, Error>) -> ()) {
        auth.signIn(withEmail: email, password: password) { [unowned self] data, error in
            if let error = error {
                completion(.failure(error))
            }
            
            if let data = data {
                adminManager.checkIfUserIsAdmin(userID: data.user.uid)
                completion(.success(nil))
            }
        }
    }
    
    /// Отправляет ссылку на почту для восстановления пароля
    /// - Parameters:
    ///   - email: Электронная почта пользователя
    ///   - completion: Возвращает Result nil либо ошибку
    func restorePassword(withEmail email: String, completion: @escaping (Result<Any?, Error>) -> ()) {
        auth.sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(nil))
            }
        }
    }
    
    // Выход из системы
    func logOut(completion: @escaping (Result<Any?, Error>) -> ()) {
        do {
            try auth.signOut()
            adminManager.notAdminAnymore()
            completion(.success(nil))
        } catch {
            completion(.failure(error))
        }
    }
    
    // Возвращает ID пользователя
    func getUserID() -> String? {
        auth.currentUser?.uid
    }
    
    // Проверяет выполнен ли вход
    func isUserLoggedIn() -> Bool {
        if auth.currentUser != nil {
            return true
        } else {
            return false
        }
    }
    
    // Удалить аккаунт пользователя
    func deleteAccount() {
        if let user = auth.currentUser {
            user.delete()
        }
    }
}
