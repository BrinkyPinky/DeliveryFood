//
//  UIImage+CompressToPNGData.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 20.03.2025.
//

import SwiftUI

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    func compressToPNGData(targetSizeInBytes: Int) -> Data? {
        let image = self
        var compressedImageData: Data?
        var scaledImage = image
        
        let targetWidth: CGFloat = 1024
        let targetHeight: CGFloat = 1024
        
        let aspectRatio = image.size.width / image.size.height
        if image.size.width > image.size.height {
            scaledImage = image.resized(to: CGSize(width: targetWidth, height: targetWidth / aspectRatio))
        } else {
            scaledImage = image.resized(to: CGSize(width: targetHeight * aspectRatio, height: targetHeight))
        }
        
        compressedImageData = scaledImage.pngData()
        
        while let data = compressedImageData, data.count > targetSizeInBytes {
            let newWidth = scaledImage.size.width * 0.9
            let newHeight = scaledImage.size.height * 0.9
            scaledImage = scaledImage.resized(to: CGSize(width: newWidth, height: newHeight))
            compressedImageData = scaledImage.pngData()
        }
        
        return compressedImageData
    }
}
