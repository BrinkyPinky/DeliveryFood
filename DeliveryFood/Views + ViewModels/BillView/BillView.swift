//
//  BillView.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 08.03.2024.
//

import SwiftUI

struct BillView: View {
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    LogotypeView(size: 64, isLeafNeeded: true)
                    Spacer()
                }
                .padding(.bottom, -8)
                
                ScrollView {
                    HStack {
                        Text("Review")
                            .font(.system(size: 24, weight: .regular, design: .default))
                        Spacer()
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 20))
                    }
                    .padding(.top)
                    DashedLine()
                    
                    ForEach(0..<3) { int in
                        HStack {
                            Text("Tart Jar")
                            Spacer()
                            Text("$ 12.50")
                        }
                        .padding([.top, .bottom])
                        
                        DashedLine()
                    }
                    HStack {
                        HStack(alignment: .bottom) {
                            Text("$")
                                .font(.system(size: 40, weight: .bold, design: .monospaced))
                            Text("37.50")
                                .font(.system(size: 50, weight: .bold, design: .rounded))
                        }
                        
                        Spacer()
                        
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(lineWidth: 1)
                            .frame(width: 50, height: 50)
                            .foregroundStyle(.gray)
                            .overlay {
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 18, weight: .bold))
                            }
                    }
                    
                    Spacer()
                }
                
                
                
            }
        }
        .padding([.leading, .trailing], 32)
    }
}

#Preview {
    BillView()
}
