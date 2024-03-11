//
//  Image Extra.swift
//  OrderApp
//
//  Created by Long Tran on 09/03/2024.
//

import UIKit


extension UIImage{
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Maintain aspect ratio
        let newSize = widthRatio > heightRatio ? CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio, height: size.height * widthRatio)

        // Create a new graphics context with the new size
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)

        // Draw the original image into the new context
        self.draw(in: rect)

        // Get the resized image
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!

        // End the graphics context
        UIGraphicsEndImageContext()

        return resizedImage
      }
}


