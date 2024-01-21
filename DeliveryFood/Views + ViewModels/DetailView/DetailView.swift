//
//  DetailView.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 21.01.2024.
//

import SwiftUI

struct DetailView: View {
    let ingredients = ["Eggs", "Vegetables", "Parmezan", "Cheese", "Tomatoes", "Onions", "Pepper", "Salt"]
    
    var body: some View {
        GeometryReader { geometryProxy in
            VStack {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading) {
                        Text("Primavera Pizza")
                            .font(.system(size: 42, weight: .black, design: .monospaced))
                            .padding(.bottom, 8)
                        HStack {
                            Text("$")
                                .foregroundStyle(.red)
                                .font(.system(size: 16, weight: .black, design: .monospaced))
                                .offset(x: 3, y: -4)
                            Text("5.99")
                                .foregroundStyle(.red)
                                .font(.system(size: 32, weight: .black, design: .monospaced))
                        }
                        .padding(.bottom)
                        HStack {
                            VStack(alignment: .leading) {
                                Spacer()
                                DetailedDescription(heading: "Grams / Calories", text: "440gr / 1700kcal")
                                Spacer()
                                
                                DetailedDescription(heading: "Crust", text: "P: 12.6G F: 8.9G C: 22.2G")
                                Spacer()
                                
                                DetailedDescription(heading: "Size", text: "Medium 14\"")
                                Spacer()
                            }
                            Image(uiImage: UIImage(named: "burger")!)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(.trailing, -48)
                        }
                        .frame(height: geometryProxy.size.height/3)
                        .padding(.bottom, 16)
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
                        Spacer()
                    }
                }
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
                            Text("Add to Order")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                            Image(systemName: "greaterthan")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                        }
                    }
            }
            .ignoresSafeArea(edges: .bottom)
            .padding([.leading,.trailing], 32)
        }
        .onAppear(perform: {
            FirebaseDatabaseManager.shared.getFoodByCategoryId(1) { foodmodel in
                print(foodmodel)
            } completionError: { error in
                print(error.message)
            }

        })
    }
}

#Preview {
    DetailView()
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
