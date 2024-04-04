//
//  CustomNavigationBarView.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 22.01.2024.
//

import SwiftUI

struct CustomNavigationBarView: View {
    let isLeafNeeded: Bool
    let isBackButtonNeeded: Bool
    let isCartButtonNeeded: Bool
    @Environment(\.presentationMode) private var presentationMode
    
    @StateObject private var coreDataManager = CoreDataManager.shared
    
    init(isLeafNeeded: Bool, isBackButtonNeeded: Bool, isCartButtonNeeded: Bool) {
        self.isLeafNeeded = isLeafNeeded
        self.isBackButtonNeeded = isBackButtonNeeded
        self.isCartButtonNeeded = isCartButtonNeeded
    }
    
    var body: some View {
        HStack {
            if isBackButtonNeeded {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 40, height: 40)
                        .foregroundStyle(.background)
                        .shadow(radius: 1)
                        .overlay {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                        }
                        .padding(.trailing, 8)
                }
                .buttonStyle(.plain)
            }
            LogotypeView(size: 32, isLeafNeeded: isLeafNeeded)
            Spacer()
            if isCartButtonNeeded {
                NavigationLink {
                    BillView()
                } label: {
                    Image(systemName: "bag")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .fontWeight(.thin)
                        .overlay {
                            if coreDataManager.billPositions.count > 0 {
                                GeometryReader(content: { geometry in
                                    Circle()
                                        .foregroundStyle(Color.red)
                                        .frame(width: 25, height: 25)
                                        .overlay {
                                            Text("\(coreDataManager.billPositions.count)")
                                                .foregroundStyle(.white)
                                                .fontWidth(.compressed)
                                        }
                                        .offset(x: geometry.size.width/2, y: -geometry.size.height/4)
                                })
                            }
                        }
                }
            }
        }
    }
}


#Preview {
    CustomNavigationBarView(isLeafNeeded: false, isBackButtonNeeded: true, isCartButtonNeeded: true)
}
