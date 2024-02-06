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
        
        
        let rotatedPoints =  rotatePoints(degrees: 270, points: pointArray, aroundOrigin: origin)
        let fitToUiKitCoordinates = fitToUikitCoordinate(image: image, viewSize: viewSize, of: rotatedPoints)
        
        
        return fitToUiKitCoordinates
    }
    
    private func fitToUikitCoordinate(image: UIImage, viewSize: CGSize, of rectanglePoints: [CGPoint]) -> [CGPoint] {
        let imageSize = image.size
        let scale = 0.75
        
        let scaleX = imageSize.width / viewSize.width
        let scaleY = imageSize.height * scale / viewSize.height
        
        let mx = viewSize.width / 2
        let my = viewSize.height / 2
        
        let ratioPoints =  rectanglePoints.map { CGPoint(x: $0.x / scaleX,
                                                         y: ($0.y / scaleY / 2)) }
        let flippedYPoints = ratioPoints.map{ CGPoint(x: $0.x,
                                                      y: my - ($0.y - my)) }
        
        let subY = (flippedYPoints[1].y - flippedYPoints[0].y) / 2
        let subX = (flippedYPoints[0].x - flippedYPoints[3].x) / 2
        
        var adjustedPoints = flippedYPoints
        adjustedPoints[0].x += subX
        adjustedPoints[1].x += subX
        adjustedPoints[2].x -= subX
        adjustedPoints[3].x -= subX
        
        adjustedPoints = adjustedPoints.map { CGPoint(x: $0.x, y: $0.y - subY) }
        
        return adjustedPoints
        
    }
    
    private func rotatePoints(degrees: CGFloat, points: [CGPoint], aroundOrigin origin: CGPoint) -> [CGPoint] {
        let radians = degrees * CGFloat.pi / 180
        return points.map { point in
            let translatedPoint = CGPoint(x: point.x - origin.x, y: point.y - origin.y)
            let affineTransform = CGAffineTransform(rotationAngle: radians)
            
            let rotatedPoint = CGPoint(
                x: affineTransform.a * translatedPoint.x + affineTransform.c * translatedPoint.y,
                y: affineTransform.b * translatedPoint.x + affineTransform.d * translatedPoint.y
            )
            
            return CGPoint(x: rotatedPoint.x + origin.x, y: rotatedPoint.y + origin.y)
        }
    }
}
