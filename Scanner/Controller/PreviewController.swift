//
//  PreviewController.swift
//  Scanner
//
//  Created by 최승범 on 2024/01/31.
//
import UIKit

final class PreviewController: UIViewController {
    private let preview = Preview()
    private let scanServiceProvider: ScanServiceProvider
    
    init(scanServiceProvider: ScanServiceProvider) {
        self.scanServiceProvider = scanServiceProvider
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("PreviewController 생성오류")
    }
    
    override func loadView() {
        view = preview
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isToolbarHidden = false
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .gray
        preview.updateImageView(image: scanServiceProvider.readScannedImage())
        preview.updatePageControlPage(numberOfPage: scanServiceProvider.scannedImages.count)
        preview.images = scanServiceProvider.scannedImages
        setupToolBarButton()
    }
}

//MARK: - configuration

extension PreviewController {
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

//MARK: - objc Action method

extension PreviewController {
    @objc func saveAction() {

    }
    
    @objc func cropAction() {
        navigationController?.pushViewController(RepointViewController(scanServiceProvider: scanServiceProvider), animated: true)
    }
    
    @objc func deleteAction() {

    }
    
    func udateImage() {
        preview.updateImageView(image: scanServiceProvider.readScannedImage())
    }
}


