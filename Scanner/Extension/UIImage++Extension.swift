//
//  UIImage++Extension.swift
//  Scanner
//
//  Created by 최승범 on 2024/02/02.
//

import UIKit

extension UIImage {
    func rotate(degrees: CGFloat) -> UIImage {
        
        let rotatedViewBox: UIView = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let affineTransform: CGAffineTransform = CGAffineTransform(rotationAngle: degrees * CGFloat.pi / 180)
        rotatedViewBox.transform = affineTransform
        
        let rotatedSize: CGSize = rotatedViewBox.frame.size
        
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap: CGContext = UIGraphicsGetCurrentContext()!

        bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)

        bitmap.rotate(by: (degrees * CGFloat.pi / 180))

        bitmap.scaleBy(x: 1.0, y: -1.0)
        bitmap.draw(cgImage!, in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height))
        
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
