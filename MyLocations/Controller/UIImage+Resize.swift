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
        
        // Calculate how big the image can be to fit inside the bounds
        let horizontalRatio = bounds.width / size.width
        let verticalRatio = bounds.height / size.height
        let ratio = min(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        // Create a new image context and draw the image into it
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
