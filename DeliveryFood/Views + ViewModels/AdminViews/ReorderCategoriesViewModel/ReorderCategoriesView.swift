//
//  ReorderCategoriesView.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 18.03.2025.
//

import SwiftUI

struct ReorderCategoriesView: View {
    @StateObject private var viewModel = ReorderCategoriesViewModel()

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                AdminCustomNavBar()
                Spacer()
                EditButton()
            }
            .padding(.horizontal)

            List {
                ForEach(viewModel.categories, id: \.id) { categoryModel in
                    NavigationLink {
                        ReorderFoodInCategoryView(food: $viewModel.food, categoryModel: categoryModel)
                            .environmentObject(viewModel)
                    } label: {
                        AdminCategoryListElement(
                            categoryModel: categoryModel,
                            showErrorWithMessage: viewModel.showErrorWithMessage
                        )
                    }
                }
                .onMove(perform: viewModel.onMove)

                NavigationLink {
                    EditOrAddNewCategoryView(order: viewModel.categories.count)
                } label: {
                    Text("Add New Category")
                        .bold()
                        .foregroundStyle(.red)
                }
                
                if !viewModel.uncategorizedFood.isEmpty {
                    Section("Uncategorized food") {
                        ForEach(viewModel.uncategorizedFood, id: \.foodID) { foodModel in
                            NavigationLink {
                                EditOrAddNewFoodView(foodModel: foodModel, currentCategory: CategoryModel(id: "", name: "", order: 92999))
                                    .environmentObject(viewModel)
                            } label: {
                                AdminFoodListElement(foodModel: foodModel, showErrorWithMessage: viewModel.showErrorWithMessage)
                            }
                        }
                    }
                }
                
                
            }
        }
        .errorMessageView(
            errorMessage: viewModel.messageText,
            isShowed: $viewModel.isErrorShowed
        )
        .onAppear {
            viewModel.onAppear()
        }
        .toolbar(.hidden)
    }
}

#Preview {
    NavigationStack {
        ReorderCategoriesView()
    }
}

private struct AdminCategoryListElement: View {
    let categoryModel: CategoryModel
    let showErrorWithMessage: (String) -> Void
    @State private var isImageLoading = true
    @State var image = UIImage()

    var body: some View {
        HStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .redacted(reason: isImageLoading ? .placeholder : .invalidated)

            Text(categoryModel.name)
                .bold()
        }
        .onAppear {
            FirebaseStorageManager.shared.downloadImage(
                withPath: "categories/\(categoryModel.id)"
            ) { result in
                switch result {
                case .success(let success):
                    guard let img = UIImage(data: success) else {
                        showErrorWithMessage(
                            "Failed to convert the photo to the desired format")
                        return
                    }
                    image = img
                    isImageLoading = false
                case .failure(let failure):
                    showErrorWithMessage(failure.localizedDescription)
                }
            }
        }
    }
}
