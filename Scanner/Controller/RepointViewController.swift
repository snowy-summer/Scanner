//
//  RepointViewController.swift
//  Scanner
//
//  Created by 최승범 on 2024/02/01.
//

import UIKit

final class RepointViewController: UIViewController {
    private let repointView = RepointView()
    private let scanServiceProvider: ScanServiceProvider
    
    init(scanServiceProvider: ScanServiceProvider) {
        self.scanServiceProvider = scanServiceProvider
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("RepointViewController 생성오류")
    }
    
    override func loadView() {
        view = repointView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(resource: .background)
        navigationController?.isToolbarHidden = true
        
        repointView.updateUI(image: scanServiceProvider.originalImages[scanServiceProvider.currentIndex])
        setupNavigationBarButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        drawRectOnRepointView(image: scanServiceProvider.originalImages[scanServiceProvider.currentIndex])
    }
}

//MARK: - configuration

extension RepointViewController {
   private func setupNavigationBarButton() {
        
        let doneButton = UIBarButtonItem(image: UIImage(systemName: "checkmark"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(doneAction))
       
       let backButton = UIBarButtonItem(image: UIImage(systemName: "arrowshape.backward.fill"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(undoAction))
       
       navigationItem.leftBarButtonItem = backButton
       navigationItem.rightBarButtonItem = doneButton
    }
}

extension RepointViewController {
    @objc private func doneAction() {
        do {
            let rectPoints = repointView.getRectPoints()
            let beforeImage = scanServiceProvider.originalImages[scanServiceProvider.currentIndex]
            let imageSize = repointView.imageView.bounds.size
            
            guard let ciImage = beforeImage.ciImage else { return }
            
            let adjustedRectPoints = scanServiceProvider.fitToCICoordinate(rectPoints: rectPoints,
                                                                           imageSize: imageSize,
                                                                           ciImageSize: ciImage.extent.size)
            
            let image = try scanServiceProvider.getCorrectPerspectiveImage(image: beforeImage, rectPoints: adjustedRectPoints)
            scanServiceProvider.changeImage(image: image, at: scanServiceProvider.currentIndex) 
            undoAction()
        } catch {
            print(error)
        }
    }
    
    @objc private func undoAction() {
        navigationController?.popViewController(animated: true)
    }
    
    private func drawRectOnRepointView(image: UIImage) {
        do {
            let viewSize = repointView.imageView.bounds.size
            let points = try scanServiceProvider.getDetectedRectanglePoint(image: image, viewSize: viewSize)
            repointView.drawRect(cgPoints: points)
            
        } catch {
            
            let viewSize = repointView.imageView.bounds.size
            let points = [
                CGPoint(x: viewSize.width * 0.2, y: viewSize.height * 0.2),
                CGPoint(x: viewSize.width * 0.8, y: viewSize.height * 0.2),
                CGPoint(x: viewSize.width * 0.8, y: viewSize.height * 0.8),
                CGPoint(x: viewSize.width * 0.2, y: viewSize.height * 0.8),
            ]
            repointView.drawRect(cgPoints: points)
            print(error)
        }
    }
}
