//
//  UIImage++Extension.swift
//  Scanner
//
//  Created by 최승범 on 2024/02/02.
//

import UIKit

extension UIImage {
//    func rotate(degrees: CGFloat) -> UIImage {
//        
//        let rotatedViewBox: UIView = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
//        let affineTransform: CGAffineTransform = CGAffineTransform(rotationAngle: degrees * CGFloat.pi / 180)
//        rotatedViewBox.transform = affineTransform
//        
//        let rotatedSize = rotatedViewBox.frame.size
//        
//        UIGraphicsBeginImageContext(rotatedSize)
//        guard let bitmap = UIGraphicsGetCurrentContext() else { return UIImage() }
//
//        bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
//
//        bitmap.rotate(by: (degrees * CGFloat.pi / 180))
//        
//        bitmap.scaleBy(x: 1.0, y: -1.0)
//        guard let cgImage = cgImage else { return UIImage() }
//        bitmap.draw(cgImage, in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height))
//        
//        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage()}
//        UIGraphicsEndImageContext()
//        
//        return newImage
//    }
    
    func rotate(degrees: CGFloat) -> UIImage {
            let radians = degrees * .pi / 180
            let newRect = CGRect(origin: .zero, size: self.size)
                .applying(CGAffineTransform(rotationAngle: radians))
            let renderer = UIGraphicsImageRenderer(size: newRect.size)

            let image = renderer.image { context in
                context.cgContext.translateBy(x: newRect.width / 2, y: newRect.height / 2)
                context.cgContext.rotate(by: radians)
                draw(in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height))
            }

            return image
        }
}
