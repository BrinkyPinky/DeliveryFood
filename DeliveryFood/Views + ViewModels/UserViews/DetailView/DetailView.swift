//
//  DetailView.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 21.01.2024.
//

import SwiftUI

struct DetailView: View {
    @StateObject private var viewModel = DetailViewModel()
    let foodModel: DetailFoodModel
    @Binding var foodImage: UIImage
    
    let isPreview: Bool
    
    init(foodModel: DetailFoodModel, foodImage: Binding<UIImage>) {
        self.foodModel = foodModel
        self._foodImage = foodImage
        self.isPreview = false
    }
    
    init(foodModel: DetailFoodModel, foodImage: Binding<UIImage>, isPreview: Bool) {
        self.foodModel = foodModel
        self._foodImage = foodImage
        self.isPreview = isPreview
    }
    
    var body: some View {
        GeometryReader { geometryProxy in
            VStack {
                VStack {
                    if isPreview {
                        CustomNavigationBarView(isLeafNeeded: true, isBackButtonNeeded: true, isCartButtonNeeded: false, isUserProfileNeeded: false)
                    } else {
                        CustomNavigationBarView(
                            isLeafNeeded: true,
                            isBackButtonNeeded: true,
                            isCartButtonNeeded: true,
                            isUserProfileNeeded: true
                        )
                    }
                }
                    .padding([.leading,.trailing], 32)
                ZStack {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading) {
                            FoodNameAndPriceView(foodModel: foodModel)
                            
                            FoodMainInformationView(geometryProxy: geometryProxy, foodModel: foodModel, foodImage: $foodImage)
                            
                            if !foodModel.ingredients.isEmpty {
                                FoodIngredientsView(ingredients: foodModel.ingredients)
                            }
                            
                            Spacer()
                        }
                    }
                    VStack {
                        Spacer()
                        AddToOrderButtonView(viewModel: viewModel, foodModel: foodModel)
                            .disabled(isPreview)
                    }
                }
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .errorMessageView(errorMessage: viewModel.errorMessage, isShowed: $viewModel.isErrorShowed)
    }
}

#Preview {
    DetailView(
        foodModel: DetailFoodModel.mock, foodImage: .constant(UIImage(systemName: "xmark")!)
    )
}

struct DetailedDescription: View {
    let heading: String
    let text: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(heading)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
            Text(text)
                .bold()
                .fontDesign(.rounded)
        }
    }
}

// MARK: Food Ingredients
struct FoodIngredientsView: View {
    let ingredients: [String]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Ingredients")
                .font(.system(size: 20, weight: .bold, design: .monospaced))
            
            LazyVGrid(columns: [GridItem(), GridItem()], alignment: .leading) {
                ForEach(ingredients, id: \.self) { element in
                    HStack {
                        Circle()
                            .frame(width: 15, height: 15)
                            .foregroundColor(.greenForSelecting)
                        Text(element)
                            .font(.system(size: 17, weight: .bold, design: .monospaced))
                    }
                }
            }
        }
        .padding([.leading,.trailing], 32)
        // AddToOrder button size
        .padding(.bottom, 100)
    }
}

// MARK: Food Main Information
struct FoodMainInformationView: View {
    let geometryProxy: GeometryProxy
    let foodModel: DetailFoodModel
    @Binding var foodImage: UIImage
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Spacer()
                DetailedDescription(heading: foodModel.heading1, text: foodModel.text1)
                Spacer()
                
                DetailedDescription(heading: foodModel.heading2, text: foodModel.text2)
                Spacer()
                
                DetailedDescription(heading: foodModel.heading3, text: foodModel.text3)
                Spacer()
            }
            Image(uiImage: foodImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .offset(x: 50, y: 0)
        }
        .padding(.leading, 32)
        .frame(height: geometryProxy.size.height/3)
        .padding(.bottom, 16)
    }
}

// MARK: Food Name And Price
struct FoodNameAndPriceView: View {
    let foodModel: DetailFoodModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(foodModel.name)
                .font(.system(size: 42, weight: .black, design: .monospaced))
                .padding(.bottom, 8)
            HStack {
                Text("$")
                    .foregroundStyle(.red)
                    .font(.system(size: 16, weight: .black, design: .monospaced))
                    .offset(x: 3, y: -4)
                Text(String(format: "%.02f", foodModel.price))
                    .foregroundStyle(.red)
                    .font(.system(size: 32, weight: .black, design: .monospaced))
            }
        }
        .padding([.leading,.trailing], 32)
        .padding(.bottom)
    }
}

struct AddToOrderButtonView: View {
    @ObservedObject var viewModel: DetailViewModel
    let foodModel: DetailFoodModel
    
    var body: some View {
        Button {
            viewModel.addToOrderAction(foodModel: foodModel)
        } label: {
            Rectangle()
                .frame(height: 100)
                .foregroundStyle(.yellow)
                .clipShape(
                    .rect(
                        topLeadingRadius: 40,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 40
                    )
                )
                .overlay {
                        HStack {
                            if !viewModel.isAnimatingNow {
                                Text("Add to Order")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .transition(.scale)
                            }
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .scaleEffect(viewModel.arrowScale)
                                .offset(x: viewModel.arrowXOffset, y: 0)
                        }
                        .foregroundStyle(.black)
                        .opacity(0.75)
                }
                .padding([.leading,.trailing], 32)
        }
        .buttonStyle(.plain)
    }
}
