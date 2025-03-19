//
//  EditOrAddNewCategoryView.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 18.03.2025.
//

import SwiftUI

struct EditOrAddNewCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: EditOrAddNewCategoryViewModel
    @Binding var categoryModel: CategoryModel

    init(categoryModel: Binding<CategoryModel>) {
        self._viewModel = StateObject(wrappedValue: EditOrAddNewCategoryViewModel(categoryModel: categoryModel.wrappedValue))
        
        self._categoryModel = categoryModel
    }
    
    init(order: Int) {
        self._viewModel = StateObject(wrappedValue: EditOrAddNewCategoryViewModel(order: order))
        self._categoryModel = .constant(CategoryModel(id: "", name: "", order: 0))
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                AdminCustomNavBar()
                
                Spacer()
                
                Button {
                    viewModel.uploadCategoryOnServer()
                } label: {
                    if viewModel.isDataUploading {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        Text("Done")
                    }
                }
                .disabled(viewModel.isDataUploading)
            }
            .padding(.horizontal)
            
            Form {
                Section {
                    HStack {
                        Image(systemName: "text.book.closed")
                        TextField("Category Name", text: $viewModel.categoryName)
                    }
                } header: {
                    HStack {
                        Spacer()
                        PickImageView(image: $viewModel.image, isImagePickerPresented: $viewModel.isImagePickerPresented)
                            .sheet(isPresented: $viewModel.isImagePickerPresented) {
                                ImagePicker(image: $viewModel.image)
                            }
                        Spacer()
                    }
                }
            }
        }
        .toolbar(.hidden)
        .errorMessageView(errorMessage: viewModel.errorMessage, isShowed: $viewModel.isErrorShowed)
        .onAppear {
            viewModel.setDismissAction(dismiss.callAsFunction)
            viewModel.onAppear()
        }
        .onDisappear {
            categoryModel.name = viewModel.categoryName
        }
    }
}

#Preview {
    EditOrAddNewCategoryView(order: 99)
}
