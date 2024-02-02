//
//  RectangleDetector.swift
//  Scanner
//
//  Created by 최승범 on 2024/02/02.
//

import CoreImage

final class RectangleDetector {
    private let detector: CIDetector = {
        let options: [String: Any] = [
            CIDetectorAccuracy: CIDetectorAccuracyHigh,
            CIDetectorMinFeatureSize: NSNumber(floatLiteral: 0.2)
        ]
        
        let detector = CIDetector(ofType: CIDetectorTypeRectangle,
                                        context: nil,
                                        options: options)
    
        return detector!
    }()
    
    func detecteRectangle(ciImage: CIImage) -> CIRectangleFeature? {
        let features = detector.features(in: ciImage)
        let rectangleFeature = features.first as? CIRectangleFeature
        
        return rectangleFeature
    }
    
    func getPrepectiveImage(ciImage: CIImage, feature: CIRectangleFeature) -> CIImage? {
        let perspectiveCorrection = CIFilter(name: CIFilterKeyName.PerspectiveCorrection.rawValue)
        perspectiveCorrection?.setValue(CIVector(cgPoint: feature.topLeft), forKey: "inputTopLeft")
        perspectiveCorrection?.setValue(CIVector(cgPoint: feature.topRight), forKey: "inputTopRight")
        perspectiveCorrection?.setValue(CIVector(cgPoint: feature.bottomRight), forKey: "inputBottomRight")
        perspectiveCorrection?.setValue(CIVector(cgPoint: feature.bottomLeft), forKey: "inputBottomLeft")
        perspectiveCorrection?.setValue(ciImage, forKey: kCIInputImageKey)
        
        let outputImage = perspectiveCorrection?.outputImage
        
        return outputImage
    }
}
