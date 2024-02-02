//
//  RepointViewController.swift
//  Scanner
//
//  Created by 최승범 on 2024/02/01.
//

import UIKit


final class RepointViewController: UIViewController {
    private let repointView = RepointView()
    
    override func loadView() {
        view = repointView
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .gray
        let image = ScanServiceProvider.shared.readOriginalImage()
        repointView.updateUI(image: image)
        setupToolBarButton()
    }
    
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
    
    
    @objc func doneAction() {

    }
    
    @objc func undoAction() {
        navigationController?.popViewController(animated: true)
    }
}
