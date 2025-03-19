//
//  EditOrAddNewFoodView.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 19.03.2025.
//

import SwiftUI

struct EditOrAddNewFoodView: View {
    @StateObject private var viewModel: EditOrAddNewFoodViewModel
    @EnvironmentObject private var reorderCategoriesViewModel:
        ReorderCategoriesViewModel
    @Environment(\.dismiss) private var dismiss

    init(order: Int, currentCategory: CategoryModel) {
        self._viewModel = StateObject(
            wrappedValue: EditOrAddNewFoodViewModel(
                order: order, currentCategory: currentCategory))
    }

    init(foodModel: DetailFoodModel, currentCategory: CategoryModel) {
        self._viewModel = StateObject(
            wrappedValue: EditOrAddNewFoodViewModel(
                foodModel: foodModel, currentCategory: currentCategory))
    }

    var body: some View {
        VStack {
            HStack {
                AdminCustomNavBar()

                Spacer()

                Button {
                    viewModel.uploadFoodOnServer()
                } label: {
                    if viewModel.isDataUploading {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        Text("Done")
                    }
                }
            }
            .animation(.default, value: viewModel.isDataUploading)
            .padding(.horizontal)

            List {
                Section {

                    HStack {
                        Image(systemName: "list.clipboard")
                        TextField("Name", text: $viewModel.name)
                    }

                    HStack {
                        Image(systemName: "dollarsign")
                        TextField(
                            "Price", value: $viewModel.price, format: .number)
                        .keyboardType(.decimalPad)
                    }

                    HStack {
                        Image(systemName: "tag")
                        Picker("Category", selection: $viewModel.pickedCategory)
                        {
                            ForEach(
                                reorderCategoriesViewModel.categories, id: \.id
                            ) { categoryModel in
                                Text(categoryModel.name)
                                    .id(categoryModel.id)
                            }
                        }
                    }

                } header: {
                    VStack(alignment: .leading) {
                        HStack {
                            Spacer()
                            PickImageView(
                                image: $viewModel.image,
                                isImagePickerPresented: $viewModel
                                    .isImagePickerPresented
                            )
                            .sheet(
                                isPresented: $viewModel.isImagePickerPresented
                            ) {
                                ImagePicker(image: $viewModel.image)
                            }
                            Spacer()
                        }
                        Text("Food Details")
                    }
                }
                Section {
                    ForEach(viewModel.ingredients.indices, id: \.self) {
                        ingredientNumber in
                        HStack {
                            Image(systemName: "leaf")
                            TextField(
                                "Ingredient Name",
                                text: Binding(
                                    get: {
                                        viewModel.ingredients[ingredientNumber]
                                    },
                                    set: {
                                        viewModel.ingredients[
                                            ingredientNumber] = $0
                                    }))
                        }
                    }
                    .onMove(perform: { from, to in
                        viewModel.ingredients.move(
                            fromOffsets: from, toOffset: to)
                    })
                    .onDelete { indexSet in
                        viewModel.ingredients.remove(atOffsets: indexSet)
                    }

                    Button {
                        viewModel.addNewIngredient()
                    } label: {
                        Text("Add New Ingredient")
                    }
                    .bold()
                    .foregroundStyle(.red)
                } header: {
                    Text("Ingredients")
                } footer: {
                    Text(
                        "You can move by pinching on the ingredient and delete by swiping left"
                    )
                }

                InfoSection(
                    text: $viewModel.text1, heading: $viewModel.heading1,
                    infoNumber: 1)
                InfoSection(
                    text: $viewModel.text2, heading: $viewModel.heading2,
                    infoNumber: 2)
                InfoSection(
                    text: $viewModel.text3, heading: $viewModel.heading3,
                    infoNumber: 3)

                Section {
                    NavigationLink("Show Detail Food Preview") {
                        DetailView(
                            foodModel: viewModel.foodModelForPreview,
                            foodImage: $viewModel.image, isPreview: true
                        )
                        .toolbar(.hidden)
                    }
                    .bold()
                    .foregroundStyle(.blue)
                }

                if !viewModel.foodModel.foodID.isEmpty {
                    Section {
                        Button("Remove Food") {
                            viewModel.isDeletionAlertShown = true
                        }
                    }
                    .alert(
                        "Are you sure",
                        isPresented: $viewModel.isDeletionAlertShown
                    ) {
                        Button("Delete", role: .destructive) {
                            viewModel.deleteFood()
                        }

                        Button("Cancel", role: .cancel) {
                            viewModel.isDeletionAlertShown = false
                        }

                    } message: {
                        Text("Press “Delete” to remove the food")
                    }

                }
            }
        }
        .toolbar(.hidden)
        .errorMessageView(
            errorMessage: viewModel.errorMessage,
            isShowed: $viewModel.isErrorShowed
        )
        .animation(.default, value: viewModel.ingredients.count)
        .onAppear {
            viewModel.onAppear(
                allCategories: reorderCategoriesViewModel.categories,
                allFoods: reorderCategoriesViewModel.food)
            viewModel.setDismissAction(dismiss.callAsFunction)
        }
        .animation(.default, value: viewModel.ingredients)
    }
}

#Preview {
    NavigationStack {
        EditOrAddNewFoodView(
            order: 50,
            currentCategory: CategoryModel(id: "", name: "Burger", order: 88))
    }
}

private struct InfoSection: View {
    @Binding var text: String
    @Binding var heading: String
    let infoNumber: Int

    var body: some View {
        Section {
            HStack {
                Image(systemName: "text.book.closed")
                TextField("Title", text: $heading)
            }
            HStack {
                Image(systemName: "text.quote")
                TextField("Caption", text: $text)
            }
        } header: {
            Text("Info №\(infoNumber)")
        }
    }
}
