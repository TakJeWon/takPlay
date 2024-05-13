//
//  UIImage+EX.swift
//  takPlay
//
//  Created by 탁제원 on 4/23/24.
//

import Foundation
import UIKit

extension UIImage {
    
    func resized(forHeight height: CGFloat) -> UIImage? {
        let originalWidth = self.size.width
        let originalHeight = self.size.height
        
        // 이미지의 비율 계산
        let aspectRatio = originalWidth / originalHeight
        
        // 새로운 이미지의 너비 계산
        let newWidth = height * aspectRatio
  
        let newSize = CGSize(width: newWidth, height: height)
        return UIGraphicsImageRenderer(size: newSize).image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
    func tiledImage(forHeight height: CGFloat) -> UIImage? {
        let originalWidth = self.size.width
        let originalHeight = self.size.height
        
        // 이미지의 비율 계산
        let aspectRatio = originalWidth / originalHeight
        
        // 새로운 이미지의 너비 계산
        let newWidth = height * aspectRatio
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: newWidth, height: height))
        return renderer.image { context in
            let numberOfTiles = Int(ceil(newWidth / originalWidth))
            for index in 0..<numberOfTiles {
                let xPosition = CGFloat(index) * originalWidth
                self.draw(at: CGPoint(x: xPosition, y: 0))
            }
        }
    }
    
    //MARK: filter image
    
    func sepiaFilter(intensity: Double) -> CIImage?
    {
        let originalImage = CIImage(image: self) ?? CIImage()
        let sepiaFilter = CIFilter(name:"CISepiaTone")
        sepiaFilter?.setValue(originalImage, forKey: kCIInputImageKey)
        sepiaFilter?.setValue(intensity, forKey: kCIInputIntensityKey)
        guard let outputImage = sepiaFilter?.outputImage else {
            return nil
        }

        // Adjust the orientation of the output image to match the input image's orientation
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            return CIImage(cgImage: cgImage, options: [CIImageOption.applyOrientationProperty: true])
        } else {
            return nil
        }
    }
    
    
    func luminanceFilter(sharpness: Double) -> CIImage?
    {
        let originalImage = CIImage(image: self) ?? CIImage()
        let luminanceFilter = CIFilter(name:"CISharpenLuminance")
        luminanceFilter?.setValue(originalImage, forKey: kCIInputImageKey)
        luminanceFilter?.setValue(sharpness, forKey: kCIInputSharpnessKey)
        guard let outputImage = luminanceFilter?.outputImage else {
            return nil
        }

        // Adjust the orientation of the output image to match the input image's orientation
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            return CIImage(cgImage: cgImage, options: [CIImageOption.applyOrientationProperty: true])
        } else {
            return nil
        }
    }
    
    func noirFilter() -> CIImage?
    {
        let originalImage = CIImage(image: self) ?? CIImage()
        let noirFilter = CIFilter(name:"CIPhotoEffectNoir")
        noirFilter?.setValue(originalImage, forKey: kCIInputImageKey)
        guard let outputImage = noirFilter?.outputImage else {
            return nil
        }

        // Adjust the orientation of the output image to match the input image's orientation
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            return CIImage(cgImage: cgImage, options: [CIImageOption.applyOrientationProperty: true])
        } else {
            return nil
        }
    }
}
