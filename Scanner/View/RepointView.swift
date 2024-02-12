//
//  RepointView.swift
//  Scanner
//
//  Created by 최승범 on 2024/02/01.
//

import UIKit
protocol CircleDelegate: AnyObject {
    func redraw()
}

final class RepointView: UIView {
    
    private (set) var imageView = UIImageView()
    private let rectLayer = CAShapeLayer()
    
    private let topLeftControlView = ControlCircle()
    private let topRightControlView = ControlCircle()
    private let bottomLeftControlView = ControlCircle()
    private let bottomRightControlView = ControlCircle()
    
    init() {
        super.init(frame: .zero)
        configureImageView()
        topLeftControlView.delegate = self
        topRightControlView.delegate = self
        bottomLeftControlView.delegate = self
        bottomRightControlView.delegate = self
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
        imageView.isUserInteractionEnabled = true
        
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

//MARK: - UI Update
extension RepointView {
    
    func updateUI(image: UIImage) {
        imageView.image = image
    }
    
    func drawRect(cgPoints: [CGPoint]) {
        
        imageView.layer.addSublayer(rectLayer)
        
        topLeftControlView.configureCircle(on: imageView, within: self, center: cgPoints[0])
        topRightControlView.configureCircle(on: imageView, within: self, center: cgPoints[1])
        
        bottomRightControlView.configureCircle(on: imageView, within: self, center: cgPoints[2])
        bottomLeftControlView.configureCircle(on: imageView, within: self, center: cgPoints[3])
        drawLine()
    }
    
    private func drawLine() {
        
        let outLine = UIBezierPath()
        
        outLine.move(to: topLeftControlView.center)
        outLine.addLine(to: topRightControlView.center)
        outLine.addLine(to: bottomRightControlView.center)
        outLine.addLine(to: bottomLeftControlView.center)
        outLine.close()
        outLine.lineJoinStyle = .round
        
        rectLayer.path = outLine.cgPath
        rectLayer.fillColor = UIColor(resource: .sub).withAlphaComponent(0.2).cgColor
        rectLayer.strokeColor = UIColor(resource: .main).cgColor
        rectLayer.lineWidth = 4
    }
    
    func getRectPoints() -> [CGPoint] {
        let rectPoints = [
            topLeftControlView.center,
            topRightControlView.center,
            bottomRightControlView.center,
            bottomLeftControlView.center
        ]
        
        return rectPoints
    }
}

extension RepointView: CircleDelegate {
    
    func redraw() {
        drawLine()
    }
}

final class ControlCircle: UIView {
    
    weak var delegate: CircleDelegate?
   
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else { return }
        let point = touch.location(in: self.superview)
        delegate?.redraw()
        DispatchQueue.main.async {
            self.center = point
        }
        
    }
    
    func configureCircle(on targetView: UIView, within containerView: UIView, center: CGPoint) {
        targetView.addSubview(self)
        self.backgroundColor = .green.withAlphaComponent(0.5)
        let circleWidth = containerView.bounds.size.width * 0.1
        
        self.bounds = CGRect(origin: CGPoint(x: 0,
                                             y: 0),
                             size: CGSize(width: circleWidth,
                                          height: circleWidth))
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.layer.cornerRadius = self.frame.width / 2
        }
        
        self.center = center
    }
}
