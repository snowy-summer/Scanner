//
//  ScanServiceProvider.swift
//  Scanner
//
//  Created by 최승범 on 2024/02/01.
//

import UIKit

final class ScanServiceProvider {
      
    private let rectangleDetector = RectangleDetector()
    private(set) var originalImages: [UIImage] = []
    private(set) var scannedImages: [UIImage] = []
    
    //MARK: - Test용 데이터 메소드
    
    func readScannedImage() -> UIImage {
        guard let image = scannedImages.last else { return UIImage() }
        return image
    }
    
    func clearImages() {
        originalImages.removeAll()
        scannedImages.removeAll()
    }
}

//MARK: - image 얻기
extension ScanServiceProvider {
    
    func getImage(image: UIImage) throws {
        originalImages.append(image)
    
        let scannedImage = try detectRectangleAndCorrectPerspective(image: image)
        scannedImages.append(scannedImage)
    }
    
    private func convertToMono(image: UIImage) throws -> CGImage {
        guard let ciImage = CIImage(image: image) else { throw ScannerError.convertToCIImageError }
        
        guard let outputImage =  rectangleDetector.convertToMono(ciImage: ciImage) else { throw DetectorError.failToConvertMonoImage }
        
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { throw ScannerError.failToCreateCGImage }
      
        return cgImage
    }
    
    private func detectRectangleAndCorrectPerspective(image: UIImage) throws -> UIImage {
        guard let ciImage = CIImage(image: image) else { throw ScannerError.convertToCIImageError }
        
        let rectangleFeature = try rectangleDetector.detecteRectangle(ciImage: ciImage)
        let outputImage = try rectangleDetector.getPrepectiveImage(ciImage: ciImage, feature: rectangleFeature)
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { throw ScannerError.failToCreateCGImage }
    
        return UIImage(cgImage: cgImage).rotate(degrees: 90)
    }
    
}

//MARK: - 좌표값 얻기
extension ScanServiceProvider {
    
    func getDetectedRectanglePoint(image: UIImage, viewSize: CGSize) throws -> [CGPoint] {
        guard let ciImage = image.ciImage else { throw ScannerError.convertToCIImageError}
        
        let rectangleFeature = try rectangleDetector.detecteRectangle(ciImage: ciImage)
        
        let origin = CGPoint(x: image.size.width / 2,
                             y: image.size.height / 2)
      
        let pointArray = [
                           rectangleFeature.topLeft,
                           rectangleFeature.topRight,
                           rectangleFeature.bottomRight,
                           rectangleFeature.bottomLeft,
                         ]
        
         let rotatedPoints =  rotatePoints(points: pointArray, byAngle: CGFloat.pi * 3 / 2, aroundOrigin: origin)
        
       
        
        return fitToUikitCoordinate(image: image, viewSize: viewSize, of: rotatedPoints)
    }
    
    private func fitToUikitCoordinate(image: UIImage, viewSize: CGSize, of rectanglePoints: [CGPoint]) -> [CGPoint] {
        
        let imageSize = image.size
        let scaleX = viewSize.width / imageSize.width
        let scaleY = viewSize.height / imageSize.height
        
        var pointArray = [CGPoint]()
        pointArray = rectanglePoints.map { CGPoint(x: $0.x * scaleX,
                                                   y: viewSize.height - ($0.y * scaleY)) }
        return pointArray
    }

    private func rotatePoints(points: [CGPoint], byAngle angle: CGFloat, aroundOrigin origin: CGPoint) -> [CGPoint] {
        return points.map { point in
            let translatedPoint = CGPoint(x: point.x - origin.x,
                                          y: point.y - origin.y)
            let rotatedPoint = CGPoint(x: cos(angle) * translatedPoint.x - sin(angle) * translatedPoint.y,
                                       y: sin(angle) * translatedPoint.x + cos(angle) * translatedPoint.y)
            
            return CGPoint(x: rotatedPoint.x + origin.x,
                           y: rotatedPoint.y + origin.y)
        }
    }
}
