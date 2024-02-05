//
//  RepointView.swift
//  Scanner
//
//  Created by 최승범 on 2024/02/01.
//

import UIKit

final class RepointView: UIView {
    
    private (set) var imageView = UIImageView()
    private let alphaLayer = CAShapeLayer()
    
    init() {
        super.init(frame: .zero)
        configureImageView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("RepointView 생성 에러")
    }
}

//MARK: - configuration
extension RepointView {
    
    private func configureImageView() {
        self.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .white
        
        let safeArea = self.safeAreaLayoutGuide
        let cameraViewConstraint = [
            imageView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(cameraViewConstraint)
    }
}


extension RepointView {
    
    func updateUI(image: UIImage) {
        imageView.image = image
    }
    
    func drawRect(cgPoints: [CGPoint]) {
        let outLine = UIBezierPath()
        outLine.move(to: cgPoints[0])
        outLine.addLine(to: cgPoints[1])
        outLine.addLine(to: cgPoints[2])
        outLine.addLine(to: cgPoints[3])
        outLine.addLine(to: cgPoints[0])
        
        alphaLayer.path = outLine.cgPath
        alphaLayer.fillColor = UIColor(resource: .sub).withAlphaComponent(0.2).cgColor
        alphaLayer.strokeColor = UIColor(resource: .main).cgColor
        alphaLayer.lineWidth = 4
    }
}

