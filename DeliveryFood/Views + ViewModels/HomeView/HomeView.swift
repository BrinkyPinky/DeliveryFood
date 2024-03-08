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
        NavigationView {
            VStack {
                CustomNavigationBarView(isLeafNeeded: false, isBackButtonNeeded: false)
                .padding([.leading, .trailing], 32)
                ScrollView(showsIndicators: false) {
                    HStack {
                        Text("Categories")
                            .bold()
                            .font(.system(size: 24))
                        
                        Spacer()
                    }
                    .padding([.leading, .trailing], 32)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 16) {
                            ForEach(viewModel.categories, id: \.id) { category in
                                CategoryView(category: category, isPicked: category.id == viewModel.pickedCategoryID)
                                    .onTapGesture {
                                        viewModel.pickedCategoryID = category.id
                                    }
                            }
                        }
                        .padding([.leading, .trailing], 32)
                    }
                    .frame(height: 190)
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Grab & Go")
                                .bold()
                                .font(.system(size: 24))
                            Spacer()
                        }
                        
                        ForEach(viewModel.featuredFood, id: \.foodID) { foodModel in
                            FeaturedByCategoryView(foodModel: foodModel)
                        }
                    }
                    .padding(.top, 16)
                    .padding([.leading, .trailing], 32)
                    
                    Spacer()
                }
            }
            .onAppear {
                viewModel.onAppearAction()
            }
        }
        .toolbar(.hidden)
    }
}

#Preview {
    HomeView()
}
