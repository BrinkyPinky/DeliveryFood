//
//  FeaturedByCategoryView.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 20.01.2024.
//

import SwiftUI

struct FeaturedByCategoryView: View {
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(Color.init(uiColor: UIColor.systemBackground))
                .shadow(color: .primary.opacity(0.2), radius: 5, x: 2, y: 2)
                .frame(height: 175)
                .overlay {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Primavera Pizza")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                            Text("200gr / 430kcal")
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            Rectangle()
                                .clipShape(
                                    .rect(
                                        topLeadingRadius: 0,
                                        bottomLeadingRadius: 20,
                                        bottomTrailingRadius: 0,
                                        topTrailingRadius: 20
                                    )
                                )
                                .foregroundStyle(.yellow)
                                .overlay {
                                    HStack {
                                        Text("$ 5.99")
                                            .font(.system(size: 18, weight: .bold, design: .rounded))
                                    }
                                }
                                .padding([.leading, .bottom], -16)
                                .padding([.trailing], 32)
                                .frame(height: 40)
                        }
                        Spacer()
                        Image(uiImage: UIImage(named: "burger")!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                    .padding()
                }
        }
    }
}

#Preview {
    FeaturedByCategoryView()
}
