//
//  UIImage+EX.swift
//  takPlay
//
//  Created by 탁제원 on 4/23/24.
//

import Foundation
import UIKit

extension UIImage {
    
    private func image(from ciImage: CIImage) -> UIImage? {
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            return UIImage(cgImage: cgImage, scale: self.scale, orientation: self.imageOrientation)
        } else {
            return nil
        }
    }
    
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
    
    func sepiaFilter(intensity: Double) -> UIImage? {
        let originalImage = CIImage(image: self) ?? CIImage()
        let sepiaFilter = CIFilter(name:"CISepiaTone")
        sepiaFilter?.setValue(originalImage, forKey: kCIInputImageKey)
        sepiaFilter?.setValue(intensity, forKey: kCIInputIntensityKey)
        guard let outputImage = sepiaFilter?.outputImage else {
            return nil
        }
        return image(from: outputImage)
    }
    
    func luminanceFilter(sharpness: Double) -> UIImage? {
        let originalImage = CIImage(image: self) ?? CIImage()
        let luminanceFilter = CIFilter(name:"CISharpenLuminance")
        luminanceFilter?.setValue(originalImage, forKey: kCIInputImageKey)
        luminanceFilter?.setValue(sharpness, forKey: kCIInputSharpnessKey)
        guard let outputImage = luminanceFilter?.outputImage else {
            return nil
        }
        return image(from: outputImage)
    }
    
    func noirFilter() -> UIImage? {
        let originalImage = CIImage(image: self) ?? CIImage()
        let noirFilter = CIFilter(name:"CIPhotoEffectNoir")
        noirFilter?.setValue(originalImage, forKey: kCIInputImageKey)
        guard let outputImage = noirFilter?.outputImage else {
            return nil
        }
        return image(from: outputImage)
    }
    
    func instantFilter() -> UIImage? {
        let originalImage = CIImage(image: self) ?? CIImage()
        let instantFilter = CIFilter(name:"CIPhotoEffectInstant")
        instantFilter?.setValue(originalImage, forKey: kCIInputImageKey)
        guard let outputImage = instantFilter?.outputImage else {
            return nil
        }
        return image(from: outputImage)
    }
    
    func coldFilter() -> UIImage? {
        let originalImage = CIImage(image: self) ?? CIImage()
        let coldFilter = CIFilter(name:"CIPhotoEffectProcess")
        coldFilter?.setValue(originalImage, forKey: kCIInputImageKey)
        guard let outputImage = coldFilter?.outputImage else {
            return nil
        }
        return image(from: outputImage)
    }
}
