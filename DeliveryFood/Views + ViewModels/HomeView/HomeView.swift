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
            VStack {
                HStack {
                    LogotypeView(size: 32, isLeafNeeded: false)
                    Spacer()
                    Image(systemName: "bag")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .fontWeight(.thin)
                }
                
                HStack {
                    Text("Categories")
                        .bold()
                        .font(.system(size: 24))
                    
                    Spacer()
                }
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
            
            VStack {
                HStack {
                    Text("Grab & Go")
                        .bold()
                        .font(.system(size: 24))
                    Spacer()
                }
                FeaturedByCategoryView()
            }
            .padding(.top, 16)
            .padding([.leading, .trailing], 32)
            
            Spacer()
        }
        .onAppear {
            viewModel.onAppearAction()
        }
    }
}

#Preview {
    HomeView()
}
