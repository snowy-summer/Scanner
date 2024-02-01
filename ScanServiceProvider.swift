//
//  ScanServiceProvider.swift
//  Scanner
//
//  Created by 최승범 on 2024/02/01.
//

import UIKit


final class ScanServiceProvider {
    
    static let shared = ScanServiceProvider()
    
    private var originalImages: [UIImage] = []
    private var scannedImages: [UIImage] = []
    
    
    func getImage(image: UIImage) {
        originalImages.append(image)
        guard let scannedImage = detectRectangleAndCorrectPerspective(image: image) else {
            print("스캔 실패")
            return
        }
        scannedImages.append(scannedImage)
    }
    
    func imagesCount() -> Int {
      return originalImages.count
    }
    
    func readScannedImage() -> UIImage {
        guard let image = scannedImages.last else { return UIImage() }
        return image
    }
    
    func readOriginalImage() -> UIImage {
        return originalImages.last!
    }
    
    func clearImages() {
        originalImages.removeAll()
        scannedImages.removeAll()
    }
    
    func detectRectangleAndCorrectPerspective(image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        // Detector 생성
        let options: [String: Any] = [
            CIDetectorAccuracy: CIDetectorAccuracyHigh,
            CIDetectorMinFeatureSize: NSNumber(floatLiteral: 0.2)
        ]
        guard let detector = CIDetector(ofType: CIDetectorTypeRectangle,
                                        context: nil,
                                        options: options) else { return nil }
        
        // Detect rectangles
        let features = detector.features(in: ciImage)
        guard let rectangleFeature = features.first as? CIRectangleFeature else { return nil }
        
        // Correct perspective
        let perspectiveCorrection = CIFilter(name: "CIPerspectiveCorrection")
        perspectiveCorrection?.setValue(CIVector(cgPoint: rectangleFeature.topLeft), forKey: "inputTopLeft")
        perspectiveCorrection?.setValue(CIVector(cgPoint: rectangleFeature.topRight), forKey: "inputTopRight")
        perspectiveCorrection?.setValue(CIVector(cgPoint: rectangleFeature.bottomRight), forKey: "inputBottomRight")
        perspectiveCorrection?.setValue(CIVector(cgPoint: rectangleFeature.bottomLeft), forKey: "inputBottomLeft")
        perspectiveCorrection?.setValue(ciImage, forKey: kCIInputImageKey)
        
        guard let outputImage = perspectiveCorrection?.outputImage else { return nil }
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
    
    
   
}
