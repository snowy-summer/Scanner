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
    var currentIndex = 0
    
    //MARK: - Test용 데이터 메소드
    
    func clearImages() {
        originalImages.removeAll()
        scannedImages.removeAll()
    }
    
    func changeImage(image: UIImage, at: Int) {
        scannedImages[at] = image
    }
    
    func deleteImage(at index: Int) {
        originalImages.remove(at: index)
        scannedImages.remove(at: index)
    }
}

//MARK: - image 얻기
extension ScanServiceProvider {
    
    func appendScannedImage(image: UIImage) throws {
        originalImages.append(image)
        
        let scannedImage = try detectRectangleAndCorrectPerspective(image: image)
        scannedImages.append(scannedImage)
    }
    
    func appendOriginalImage(image: UIImage) {
        scannedImages.append(image)
    }
    
    private func detectRectangleAndCorrectPerspective(image: UIImage) throws -> UIImage {
        guard let ciImage = image.ciImage else { throw ScannerError.convertToCIImageError }
        
        let rectangleFeature = try rectangleDetector.detecteRectangle(ciImage: ciImage)
        let outputImage = try rectangleDetector.getPrepectiveImage(ciImage: ciImage, feature: rectangleFeature)
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { throw ScannerError.failToCreateCGImage }
        return UIImage(cgImage: cgImage)
    }
    
    func getCorrectPerspectiveImage(image: UIImage, rectPoints: [CGPoint]) throws -> UIImage {

        guard let ciImage = image.ciImage else { throw ScannerError.convertToCIImageError }
        
        let outputImage = try rectangleDetector.getPrepectiveImage(ciImage: ciImage, points: rectPoints)
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { throw ScannerError.failToCreateCGImage }
        return UIImage(cgImage: cgImage)
    }
    
    
}

//MARK: - 좌표값 얻기
extension ScanServiceProvider {
    
    func getDetectedRectanglePoint(image: UIImage, viewSize: CGSize) throws -> [CGPoint] {
        guard let ciImage = image.ciImage else { throw ScannerError.convertToCIImageError}
        
        let rectangleFeature = try rectangleDetector.detecteRectangle(ciImage: ciImage)
        
        let pointArray = [
            rectangleFeature.topLeft,
            rectangleFeature.topRight,
            rectangleFeature.bottomRight,
            rectangleFeature.bottomLeft,
        ]
        
        let fitToUiKitCoordinates = fitToUikitCoordinate(image: image, viewSize: viewSize, of: pointArray)
        
        return fitToUiKitCoordinates
    }
    
    private func fitToUikitCoordinate(image: UIImage, viewSize: CGSize, of rectanglePoints: [CGPoint]) -> [CGPoint] {
        let imageSize = image.size
        
        let scaleX = imageSize.width / viewSize.width
        let scaleY = imageSize.height / viewSize.height
        
        let adjustedPoints = rectanglePoints.map { CGPoint(x: $0.x / scaleX, y: viewSize.height - ($0.y / scaleY)) }
        
        return adjustedPoints
    }
}
