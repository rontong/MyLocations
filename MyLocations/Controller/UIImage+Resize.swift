//
//  UIImage+Resize.swift
//  MyLocations
//
//  Created by Ronald Tong on 8/8/18.
//  Copyright © 2018 StokeDesign. All rights reserved.
//

import UIKit
extension UIImage {
    func resizedImage(withBounds bounds: CGSize) -> UIImage {
        
        // Calculate how big the image can be to fit inside the bounds. Max ratio for aspect fill, min ratio for aspect fit.
        let horizontalRatio = bounds.width / size.width
        let verticalRatio = bounds.height / size.height
        let ratio = max(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        // Create a new image context and cut the image to the given bounds (52 by 52)
        UIGraphicsBeginImageContextWithOptions(bounds, true, 0)
        
        // Calculate origin point to center the image
        let originPoint = CGPoint(x: min((bounds.width - newSize.width), CGPoint.zero.x), y: min((bounds.height - newSize.height), CGPoint.zero.y))
        draw(in: CGRect(origin: originPoint, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

