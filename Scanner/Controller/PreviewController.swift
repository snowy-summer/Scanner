//
//  PreviewController.swift
//  Scanner
//
//  Created by 최승범 on 2024/01/31.
//
import UIKit

final class PreviewController: UIViewController {
    let preview = Preview()
    
    override func loadView() {
        view = preview
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isToolbarHidden = false
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .gray
        preview.updateImageView(image: ScanServiceProvider.shared.readScannedImage())
        navigationController?.isToolbarHidden = false
        setupToolBarButton()
    }
    
    
    @objc func saveAction() {

    }
    
    @objc func cropAction() {
        navigationController?.pushViewController(RepointViewController(), animated: true)
    }
    
    @objc func deleteAction() {

    }
    
    func setupToolBarButton() {

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                            target: nil,
                                            action: nil)
        
        let finishButton = UIBarButtonItem(title: "반시계",
                                           style: .plain,
                                           target: self,
                                           action: #selector(saveAction))
        
        let deleteButton = UIBarButtonItem(image: UIImage(systemName: "trash.fill"),
                                           style: .plain,
                                           target: self,
                                           action: #selector(deleteAction))
        
        let cropButton = UIBarButtonItem(image: UIImage(systemName: "crop"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(cropAction))
        
        let barItems = [ flexibleSpace, deleteButton,
                         flexibleSpace, flexibleSpace, finishButton, flexibleSpace, flexibleSpace,
                         cropButton, flexibleSpace ]

        toolbarItems = barItems
    }
}
