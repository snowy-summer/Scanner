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
        
       guard let detector = CIDetector(ofType: CIDetectorTypeRectangle,
                                        context: nil,
                                       options: options) else {
           return CIDetector()
       }
    
        return detector
    }()
    
    func detecteRectangle(ciImage: CIImage) throws -> CIRectangleFeature {
        let features = detector.features(in: ciImage)
        guard let rectangleFeature = features.first as? CIRectangleFeature else { throw DetectorError.failToDetectRectangle }
        
        return rectangleFeature
    }
    
    
    func convertToMono(ciImage: CIImage) -> CIImage? {
        let monofilter = CIFilter(name: CIFilterKeyName.mono.rawValue)
        monofilter?.setValue(ciImage, forKey: kCIInputImageKey)
        
        let outputImage = monofilter?.outputImage
        return outputImage
    }
    
    func getPrepectiveImage(ciImage: CIImage, feature: CIRectangleFeature) throws -> CIImage {
        let perspectiveCorrection = CIFilter(name: CIFilterKeyName.PerspectiveCorrection.rawValue)
        perspectiveCorrection?.setValue(CIVector(cgPoint: feature.topLeft), forKey: "inputTopLeft")
        perspectiveCorrection?.setValue(CIVector(cgPoint: feature.topRight), forKey: "inputTopRight")
        perspectiveCorrection?.setValue(CIVector(cgPoint: feature.bottomRight), forKey: "inputBottomRight")
        perspectiveCorrection?.setValue(CIVector(cgPoint: feature.bottomLeft), forKey: "inputBottomLeft")
        perspectiveCorrection?.setValue(ciImage, forKey: kCIInputImageKey)
        
        guard let outputImage = perspectiveCorrection?.outputImage else { throw DetectorError.failToGetPerspectiveCorrectionImage }
        
        return outputImage
    }
}
