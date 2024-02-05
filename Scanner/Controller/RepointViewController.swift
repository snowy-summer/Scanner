//
//  RepointViewController.swift
//  Scanner
//
//  Created by 최승범 on 2024/02/01.
//

import UIKit

final class RepointViewController: UIViewController {
    private let repointView = RepointView()
    private let alphaLayer = CAShapeLayer()
    private let scanServiceProvider = ScanServiceProvider.shared
    
    override func loadView() {
        view = repointView
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .gray
        navigationController?.navigationBar.isHidden = true
        let image = scanServiceProvider.readOriginalImage()
        repointView.layer.addSublayer(alphaLayer)
        repointView.updateUI(image: image)
        setupToolBarButton()
        drawRect(image: image)
    }
}

//MARK: - configuration

extension RepointViewController {
    func setupToolBarButton() {

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                            target: nil,
                                            action: nil)
  
        let undoButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"),
                                         style: .plain,
                                           target: self,
                                           action: #selector(undoAction))
        
        let doneButton = UIBarButtonItem(image: UIImage(systemName: "checkmark"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(doneAction))
        
        let fixedButtonSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedButtonSpace.width = undoButton.width
        

        
        
        let barItems = [ flexibleSpace, undoButton,
                         flexibleSpace, flexibleSpace, fixedButtonSpace, flexibleSpace, flexibleSpace,
                         doneButton, flexibleSpace ]

        toolbarItems = barItems
    }
}

//MARK: - objc Action method

extension RepointViewController {
    @objc func doneAction() {

    }
    
    @objc func undoAction() {
        navigationController?.popViewController(animated: true)
    }
}

extension RepointViewController {
    func drawRect(image: UIImage) {
        do {
            let viewSize = view.bounds.size
            let points = try scanServiceProvider.getDetectedRectanglePoint(image: image, viewSize: viewSize)
           
            drawRect(cgPoints: points)
            
        } catch {
            print(error)
        }
    }

    private func drawRect(cgPoints: [CGPoint]) {
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
