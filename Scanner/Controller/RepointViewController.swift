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
        super.loadView()
        view = repointView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .gray
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
       
       let backButton = UIBarButtonItem(image: UIImage(systemName: "arrowshape.backward"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(undoAction))
       
       navigationItem.leftBarButtonItem = backButton
       navigationItem.rightBarButtonItem = doneButton
    }
}

//MARK: - objc Action method

extension RepointViewController {
    @objc private func doneAction() {
        do {
            let rectPoints = repointView.getRectPoints()
            guard let beforeImage = repointView.imageView.image else { return }
            let image = try scanServiceProvider.getCorrectPerspectiveImage(image: beforeImage, rectPoints: rectPoints)
            repointView.updateUI(image: image)
        } catch {
            print(error)
        }
    }
    
    @objc private func undoAction() {
        navigationController?.popViewController(animated: true)
    }
}

extension RepointViewController {
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
