//
//  LogotypeView.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 18.01.2024.
//

import SwiftUI

struct LogotypeView: View {
    let size: CGFloat
    let isLeafNeeded: Bool
    
    var body: some View {
        ZStack {
            
            Text("Deli")
                .font(.custom("Vetka", size: size))
                .background {
                    if isLeafNeeded {
                        HStack {
                            VStack {
                                Image(uiImage: UIImage(named: "logoBackground")!)
                                    .resizable()
                                    .frame(width: size/1.5, height: size/2.5, alignment: .topLeading)
                                    .rotationEffect(.degrees(135))
                                Spacer()
                            }
                            Spacer()
                        }
                        .offset(x: -size/6, y: 0)
                    }
                }
        }
    }
}

#Preview {
    LogotypeView(size: 64, isLeafNeeded: true)
}
