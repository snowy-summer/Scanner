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
        view.backgroundColor = .gray
        navigationController?.navigationBar.isHidden = true
        guard let image = scanServiceProvider.originalImages.last else {
            //촬영한 이미지가 없다고 알려야 할듯
            return
        }
        
        repointView.updateUI(image: image)
        setupToolBarButton()
        drawRectOnRepointView(image: image)
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
    func drawRectOnRepointView(image: UIImage) {
        do {
            let viewSize = repointView.imageView.bounds.size
            
            let points = try scanServiceProvider.getDetectedRectanglePoint(image: image, viewSize: viewSize)
            
            repointView.drawRect(cgPoints: points)
            
        } catch {
            print(error)
        }
    }
}
