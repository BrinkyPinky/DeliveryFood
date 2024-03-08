//
//  FeaturedByCategoryViewModel.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 22.01.2024.
//

import Foundation
import SwiftUI

class FeaturedByCategoryViewModel: ObservableObject {
    @Published var animationMainTextOpacity: Double = 1
    @Published var animationSuccessTextScale: CGFloat = 0
    
    private var isAlreadyAddingToCart = false
    
    func startAddToCartAnimation() {
        if !isAlreadyAddingToCart {
            isAlreadyAddingToCart = true
            withAnimation(.easeInOut(duration: 0.1)) {
                animationMainTextOpacity = 0
            } completion: { [self] in
                withAnimation(.easeInOut(duration: 0.2)) {
                    animationSuccessTextScale = 1
                } completion: { [self] in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [self] in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            animationSuccessTextScale = 0
                            animationMainTextOpacity = 1
                        } completion: { [self] in
                            isAlreadyAddingToCart = false
                        }
                    }
                }
            }
        }
    }
}
