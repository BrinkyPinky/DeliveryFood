//
//  FeaturedByCategoryViewModel.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 22.01.2024.
//

import Foundation
import SwiftUI

final class FeaturedByCategoryViewModel: ObservableObject {
    //animation
    @Published var animationMainTextOpacity: Double = 1
    @Published var animationSuccessTextScale: CGFloat = 0
    private var isAlreadyAddingToCart = false
    
    //image
    var foodImage = UIImage()
    @Published var isImageLoading = true
    
    //error
    let showError: (String) -> ()
    
    //ViewModel которая подгружает картинку
    init(showError: @escaping (String) -> Void) {
        self.showError = showError
    }
    
    //ViewModel пустышка которая ждет подгрузки основных данных
    init() {
        self.showError = { _ in }
        
    }
    
    /// Добавление в корзину с анимацией
    /// - Parameter foodModel: для сохранения в coredata
    func addToCartAction(foodModel: DetailFoodModel) {
        if !isAlreadyAddingToCart {
            isAlreadyAddingToCart = true
            withAnimation(.easeInOut(duration: 0.1)) {
                animationMainTextOpacity = 0
            } completion: { [self] in
                withAnimation(.easeInOut(duration: 0.2)) {
                    animationSuccessTextScale = 1
                } completion: { [self] in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
                        guard let self = self else { return }
                        withAnimation(.easeInOut(duration: 0.2)) {
                            self.animationSuccessTextScale = 0
                            self.animationMainTextOpacity = 1
                            
                            do {
                                try BillCoreDataManager.shared.addBillPosition(foodModel: foodModel)
                            } catch let error as CoreDataError {
                                self.showError(error.localizedDescription)
                            } catch {
                                self.showError(error.localizedDescription)
                            }
                        } completion: { [self] in
                            self.isAlreadyAddingToCart = false
                        }
                    }
                }
            }
        }
    }
    
    /// Срабатывает при появлении и скачивает изображение из FirebaseStorage
    /// - Parameter imageURL: ссылка на изображение в FirebaseStrorage
    func onAppear(foodModel: DetailFoodModel) {
        FirebaseStorageManager.shared.downloadImage(withPath: "food/\(foodModel.foodID)") { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                guard let image = UIImage(data: data) else {
                    self.showError("Failed to convert image.\nPlease report the bug")
                    return
                }
                
                self.foodImage = image
                self.isImageLoading = false
            case .failure(let error):
                if let error = error as? FirebaseFirestoreError {
                    self.showError(error.localizedDescription)
                } else {
                    self.showError(error.localizedDescription)
                }
            }
        }
    }
}
