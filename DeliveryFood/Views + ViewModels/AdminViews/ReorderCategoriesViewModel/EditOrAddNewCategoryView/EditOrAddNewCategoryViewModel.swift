//
//  EditOrAddNewCategoryViewModel.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 19.03.2025.
//

import Foundation
import SwiftUI

final class EditOrAddNewCategoryViewModel: ObservableObject {
    @Published var categoryName = ""
    
    // Image Picker
    @Published var isImagePickerPresented = false
    @Published var image = UIImage()
    @Published var isImageWasPicked = false
    
    @Published var isDataUploading = false

    var categoryModel: CategoryModel
    
    var dismissAction: (() -> Void)?

    // Error View
    @Published var isErrorShowed = false
    var errorMessage = ""

    init(categoryModel: CategoryModel) {
        self.categoryModel = categoryModel
        self.categoryName = categoryModel.name
    }
    
    init(order: Int) {
        var categoryModelRef = CategoryModel(id: "", name: "", order: 0)
        categoryModelRef.order = order
        self.categoryModel = categoryModelRef
    }

    private func showErrorWithMessage(_ message: String) {
        errorMessage = message
        isErrorShowed = true
    }
    
    func setDismissAction(_ dismiss: @escaping () -> Void) {
        dismissAction = dismiss
    }
    
    func onAppear() {
        guard !categoryModel.id.isEmpty else { return }
        
        FirebaseStorageManager.shared.downloadImage(withPath: "categories/\(categoryModel.id)") { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let success):
                guard let image = UIImage(data: success) else {
                    showErrorWithMessage(AdminError.imageConvertError.localizedDescription)
                    return
                }
                
                self.image = image
            case .failure(let failure):
                showErrorWithMessage(failure.localizedDescription)
            }
        }
    }

    func uploadCategoryOnServer() {
        guard !categoryName.isEmpty else {
            showErrorWithMessage(AdminError.unfilledFieldsError.localizedDescription)
            return
        }
        
        guard !isDataUploading else { return }
        isDataUploading = true
        
        guard let pngData = image.pngData() else {
            showErrorWithMessage(AdminError.imageConvertError.localizedDescription)
            isDataUploading = false
            return
        }
        
        categoryModel.name = categoryName
        
        FirebaseFirestoreAdminManager.shared.uploadNewOrChangeExistingCategory(category: categoryModel, image: image, isNeedToUploadPhoto: isImageWasPicked) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(_):
                isDataUploading = false
                dismissAction?()
            case .failure(let error):
                showErrorWithMessage(error.localizedDescription)
                isDataUploading = false
            }
        }
    }
}
