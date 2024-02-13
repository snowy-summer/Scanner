//
//  ControlCircle.swift
//  Scanner
//
//  Created by 최승범 on 2024/02/13.
//

import UIKit

final class ControlCircle: UIView {
    
    weak var delegate: CircleDelegate?
    private let mainQueue = DispatchQueue.main
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else { return }
        let point = touch.location(in: self.superview)
        delegate?.redraw()
        
        mainQueue.async { [weak self] in
            self?.center = point
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
        
        mainQueue.async { [weak self] in
            guard let self = self else { return }
            self.layer.cornerRadius = self.frame.width / 2
        }
        
        
        self.center = center
    }
}
