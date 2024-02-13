//
//  PreviewController.swift
//  Scanner
//
//  Created by 최승범 on 2024/01/31.
//
import UIKit

protocol PreviewDelegate: AnyObject {
    func changeNavigationTitle()
}

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
        super.loadView()
        view = preview
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isToolbarHidden = false
        navigationController?.navigationBar.isHidden = false
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
        preview.delegate = self
        preview.updateImageView(image: scanServiceProvider.readScannedImage())
        preview.updatePageControlPage(numberOfPage: scanServiceProvider.scannedImages.count)
        preview.scannedImages = scanServiceProvider.scannedImages
        setupToolBarButton()
        changeNavigationTitle()
    }
}

//MARK: - configuration

extension PreviewController {
    private func setupToolBarButton() {
        
        let backButton = UIBarButtonItem(image: UIImage(systemName: "arrowshape.backward"),
                                          style: .plain,
                                          target: self,
                                          action: #selector(backAction))
        
        navigationItem.leftBarButtonItem = backButton
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                            target: nil,
                                            action: nil)
        
        let rotateButton = UIBarButtonItem(title: "반시계",
                                           style: .plain,
                                           target: self,
                                           action: #selector(rotateAction))
        
        let deleteButton = UIBarButtonItem(image: UIImage(systemName: "trash.fill"),
                                           style: .plain,
                                           target: self,
                                           action: #selector(deleteAction))
        
        let cropButton = UIBarButtonItem(image: UIImage(systemName: "crop"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(pushRepointViewController))
        
        let barItems = [ flexibleSpace, deleteButton,
                         flexibleSpace, flexibleSpace, rotateButton, flexibleSpace, flexibleSpace,
                         cropButton, flexibleSpace ]
        
        toolbarItems = barItems
    }
}

//MARK: - objc Action method

extension PreviewController {
    @objc private func rotateAction() {
        guard let image = preview.currentImageOfImageView() else { return }
        let rotatedImage = image.rotate(degrees: 90)
        let index = preview.pageControl.currentPage
        scanServiceProvider.changeImage(image: rotatedImage, at: index)
        preview.scannedImages[index] = rotatedImage
        preview.updateImageView(image: rotatedImage)
    }
    
    @objc private func pushRepointViewController() {
        navigationController?.pushViewController(RepointViewController(scanServiceProvider: scanServiceProvider), animated: true)
    }
    
    @objc private func deleteAction() {
        // TODO: 사진삭제 -> 다음 사진 보여줘야함
        if !scanServiceProvider.scannedImages.isEmpty {
            scanServiceProvider.deleteImage(at: preview.pageControl.currentPage)
            preview.updatePageControlPage(numberOfPage: scanServiceProvider.scannedImages.count)
            changeNavigationTitle()
        }
    }
    
    @objc private func backAction() {
        navigationController?.popViewController(animated: true)
    }
}

//MARK: - PreviewDelegate
extension PreviewController: PreviewDelegate {
    func changeNavigationTitle() {
        self.title = "\(preview.pageControl.currentPage + 1) / \(preview.pageControl.numberOfPages)"
    }
}
