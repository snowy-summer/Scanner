//
//  ScannedImage.swift
//  Scanner
//
//  Created by 최승범 on 2024/02/01.
//

import UIKit

class ScannedImage {
    private var images: [UIImage] = []
    private var scannedImage: [UIImage] = []
    
     func addOriginalImage(image: UIImage) {
        images.append(image)
    }
    
    func addScannedImage(image: UIImage) {
        scannedImage.append(image)
    }
    
}
