//
//  ContentView.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 18.01.2024.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        VStack {
            CustomNavigationBarView(
                isLeafNeeded: true,
                isBackButtonNeeded: false,
                isCartButtonNeeded: true,
                isUserProfileNeeded: true
            )
            .padding([.leading, .trailing], 32)
            ScrollView(showsIndicators: false) {
                CategoriesSection(viewModel: viewModel)

                FeaturedFoodSection(viewModel: viewModel)

                Spacer()
            }
        }
        .toolbar(.hidden)
        .onAppear {
            viewModel.onAppearAction()
        }
        .onChange(of: viewModel.pickedCategoryID) { _, _ in
            viewModel.loadFeaturedFood()
        }
        .errorMessageView(
            errorMessage: viewModel.errorMessage,
            isShowed: $viewModel.isErrorShowed)
    }
}

#Preview {
    HomeView()
}


struct CategoriesSection: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        HStack {
            Text("Categories")
                .bold()
                .font(.system(size: 24))

            Spacer()
        }
        .padding([.leading, .trailing], 32)

        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {

                //Если категории загружается то показываются пустышки
                if viewModel.isCategoriesLoading {
                    ForEach(0..<4) { _ in
                        CategoryView()
                            .disabled(true)
                            .redacted(reason: .placeholder)
                            .opacity(0.5)
                    }
                    .padding([.top, .bottom], 50)
                } else {
                    ForEach(viewModel.categories, id: \.id) {
                        category in
                        CategoryView(
                            category: category,
                            isPicked: category.id
                                == viewModel.pickedCategoryID,
                            showError: viewModel.showError
                        )
                        .onTapGesture {
                            viewModel.pickedCategoryID = category.id
                        }
                    }
                    .padding([.top, .bottom], 50)
                }
            }
            .padding([.leading, .trailing], 32)
            .animation(
                .easeInOut(duration: 0.2),
                value: viewModel.isCategoriesLoading)
        }
        .frame(height: 205)
    }
}

struct FeaturedFoodSection: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Grab & Go")
                    .bold()
                    .font(.system(size: 24))
                Spacer()
            }
            LazyVStack {

                //Если предложенная еда загружается то показываются пустышки
                if viewModel.isFeaturedFoodLoading {
                    ForEach(0..<5) { _ in
                        FeaturedByCategoryView()
                    }
                    .disabled(true)
                    .redacted(reason: .placeholder)
                } else {
                    ForEach(viewModel.featuredFood, id: \.foodID) {
                        foodModel in
                        FeaturedByCategoryView(
                            foodModel: foodModel,
                            showError: viewModel.showError)
                    }
                }
            }
        }
        .padding(.top, 16)
        .padding([.leading, .trailing], 32)
        .animation(
            .easeInOut(duration: 0.2),
            value: viewModel.isFeaturedFoodLoading)
    }
}
