//
//  LaunchScreenViewModifier.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 04.04.2024.
//

import SwiftUI

struct LaunchScreenViewModifier: ViewModifier {
    //screenSize
    @State private var geometrySize = CGSize(width: 0, height: 0)
    
    //textAnimation
    @State private var textScale: CGFloat = 0
    @State private var textRotation: Double = 0
    
    //backgroundImageAnimation
    @State private var imageShowingWidth: CGFloat = 0
    @State private var imageShowingHeight: CGFloat = 0
    
    @Binding var isShowed: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        
                        ZStack {
                            Color(uiColor: UIColor.systemBackground)
                                .scaleEffect(x: 1.5, y: 1.5)
                            Image(uiImage: UIImage(named: "launchScreenAnimationBackground.png")!)
                                .resizable()
                                .scaledToFill()
                                .frame(width: geometry.size.width*1.5)
                                .position(x: geometry.size.width/2, y: geometry.size.height/2)
                                .offset(x: -geometry.size.width*0.04, y: 0)
                                .mask {
                                    RoundedRectangle(cornerRadius: 100)
                                        .frame(width: imageShowingWidth, height: imageShowingHeight)
                                }
                            
                            Text("Deli")
                                .font(.custom("Vetka", size: textScale, relativeTo: .title))
                                .rotationEffect(.degrees(textRotation))
                            
                            VStack {
                                Spacer()
                            }
                        }
                        
                        Spacer()
                    }
                    Spacer()
                }
                .onAppear {
                    startAnimation(size: geometry.size)
                }
            }
            .ignoresSafeArea(edges: .all)
            .opacity(isShowed ? 1 : 0)
        }
    }
    
    private func startAnimation(size: CGSize) {
        withAnimation(.easeInOut(duration: 0.5)) {
            textScale = size.width / 3
            textRotation = 4
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.75)) {
                textRotation = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    imageShowingWidth = size.width * 2
                    imageShowingHeight = size.height
                }
            }
        }
    }
}

extension View {
    func launchScreenViewModifier(isShowed: Binding<Bool>) -> some View {
        modifier(LaunchScreenViewModifier(isShowed: isShowed))
    }
}

#Preview {
    Text("")
        .launchScreenViewModifier(isShowed: .constant(true))
}

