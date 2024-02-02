//
//  ScanServiceProvider.swift
//  Scanner
//
//  Created by 최승범 on 2024/02/01.
//

import UIKit

final class ScanServiceProvider {
    
    static let shared = ScanServiceProvider()
    
    private let rectangleDetector = RectangleDetector()
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
    
    //MARK: - Test용 데이터 메소드
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
    
    func drawRectangle(view: UIView, image: UIImage) {
        let sublayer = CAShapeLayer()
        
        guard let ciImage = CIImage(image: image) else { return }
        
        guard let rectangleFeature = rectangleDetector.detecteRectangle(ciImage: ciImage) else { return }
        
        let bezierPath = UIBezierPath()
        
        bezierPath.addArc(withCenter: rectangleFeature.topLeft,
                          radius: 20,
                          startAngle: 0,
                          endAngle: CGFloat.pi * 2,
                          clockwise: true)
        bezierPath.addLine(to: rectangleFeature.topRight)
        
        bezierPath.addArc(withCenter: rectangleFeature.topRight,
                          radius: 20,
                          startAngle: 0,
                          endAngle: CGFloat.pi * 2,
                          clockwise: true)
        bezierPath.addLine(to: rectangleFeature.bottomRight)
        
        bezierPath.addArc(withCenter: rectangleFeature.bottomRight,
                          radius: 20,
                          startAngle: 0,
                          endAngle: CGFloat.pi * 2,
                          clockwise: true)
        bezierPath.addLine(to: rectangleFeature.bottomLeft)
        
        bezierPath.addArc(withCenter: rectangleFeature.bottomLeft,
                          radius: 20,
                          startAngle: 0,
                          endAngle: CGFloat.pi * 2,
                          clockwise: true)
        bezierPath.addLine(to: rectangleFeature.topLeft)
        bezierPath.lineWidth = 4
        
        sublayer.path = bezierPath.cgPath
        sublayer.fillColor = UIColor.red.cgColor
        view.layer.addSublayer(sublayer)
    }
    
    func detectRectangleAndCorrectPerspective(image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        guard let rectangleFeature = rectangleDetector.detecteRectangle(ciImage: ciImage) else { return nil}
        
        guard let outputImage =  rectangleDetector.getPrepectiveImage(ciImage: ciImage, feature: rectangleFeature) else { return nil }
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage).rotate(degrees: 90)
    }
    
    func getDetectedRectanglePoint(image: UIImage) -> [CGPoint]? {
        guard let ciImage = CIImage(image: image) else { return nil}
        
        guard let rectangleFeature = rectangleDetector.detecteRectangle(ciImage: ciImage) else { return nil}
        
        var pointArray = [CGPoint]()
        pointArray.append(rectangleFeature.topLeft)
        pointArray.append(rectangleFeature.topRight)
        pointArray.append(rectangleFeature.bottomLeft)
        pointArray.append(rectangleFeature.bottomRight)
        
        return pointArray
    }
}
