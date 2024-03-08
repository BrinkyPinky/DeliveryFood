//
//  DetailViewModel.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 22.01.2024.
//

import SwiftUI

class DetailViewModel: ObservableObject {
    @Published var isAnimatingNow = false
    
    @Published var arrowScale: CGFloat = 1
    @Published var arrowXOffset: CGFloat = 0
    
    func startAddToOrderAnimation() {
        if !isAnimatingNow {
            withAnimation(.easeInOut(duration: 0.2)) {
                
                isAnimatingNow = true
                
            } completion: { [self] in
                withAnimation(.easeOut(duration: 0.2)) {
                    
                    arrowScale = 2
                    
                } completion: { [self] in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        
                        arrowScale = 0
                        arrowXOffset = 100
                        
                    } completion: { [self] in
                        
                        arrowXOffset = 0
                        
                        withAnimation(.easeInOut(duration: 0.2)) {
                            
                            arrowScale = 1
                            isAnimatingNow = false
                            
                        }
                    }
                }
            }
        }
    }
}
