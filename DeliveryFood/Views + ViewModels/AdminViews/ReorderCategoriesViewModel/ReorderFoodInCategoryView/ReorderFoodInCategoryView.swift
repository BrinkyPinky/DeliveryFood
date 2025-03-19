//
//  ReorderFoodInCategoryView.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 18.03.2025.
//

import SwiftUI

struct ReorderFoodInCategoryView: View {
    @StateObject private var viewModel = ReorderFoodInCategoryViewModel()
    @Binding var food: [DetailFoodModel]
    @State var categoryModel: CategoryModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var reorderCategoriesViewModel: ReorderCategoriesViewModel

    var body: some View {
        VStack {
            HStack {
                AdminCustomNavBar()
                Spacer()
                EditButton()
            }
            .padding(.horizontal)

            List {
                Section(categoryModel.name) {
                    NavigationLink {
                        EditOrAddNewCategoryView(
                            categoryModel: $categoryModel)
                    } label: {
                        Text("Edit Category")
                    }
                    
                    Button {
                        viewModel.isDeletionAlertShown = true
                    } label: {
                        Text("Remove Category")
                    }
                    .foregroundStyle(.red)
                    .bold()
                    .alert("Are you sure", isPresented: $viewModel.isDeletionAlertShown) {
                        Button("Delete", role: .destructive) {
                            viewModel.deleteCategory(categoryModel: categoryModel)
                        }
                        
                        Button("Cancel", role: .cancel) {
                            viewModel.isDeletionAlertShown = false
                        }
                        
                    } message: {
                        Text("Press “Delete” to remove the food")
                    }
                }
                
                Section("Food In Category") {
                    ForEach(viewModel.foodInCategory, id: \.foodID) { foodModel in
                        NavigationLink {
                            EditOrAddNewFoodView(foodModel: foodModel, currentCategory: categoryModel)
                                .environmentObject(reorderCategoriesViewModel)
                        } label: {
                            AdminFoodListElement(foodModel: foodModel, showErrorWithMessage: viewModel.showErrorWithMessage)
                        }
                    }
                    .onMove(perform: viewModel.onMove)
                    
                    NavigationLink {
                        EditOrAddNewFoodView(order: viewModel.foodInCategory.count, currentCategory: categoryModel)
                            .environmentObject(reorderCategoriesViewModel)
                    } label: {
                        Text("Add New Food")
                    }
                    .bold()
                    .foregroundStyle(.red)

                }
            }

        }
        .disabled(viewModel.isDataUploading)
        .toolbar(.hidden)
        .onAppear {
            reorderCategoriesViewModel.onAppear()
            viewModel.setDismissAction(dismiss.callAsFunction)
            viewModel.filterAndSortFoodForCurrentCategory(food: food, currentCategory: categoryModel)
        }
        .onChange(of: food, { _, newValue in
            viewModel.filterAndSortFoodForCurrentCategory(food: newValue, currentCategory: categoryModel)
        })
        .errorMessageView(errorMessage: viewModel.errorMessage, isShowed: $viewModel.isErrorShowed)
    }
}

#Preview {
    NavigationStack {
        ReorderFoodInCategoryView(
            food: .constant([.mock, .mock, .mock]),
            categoryModel: CategoryModel(id: "", name: "", order: 0))
    }
}
