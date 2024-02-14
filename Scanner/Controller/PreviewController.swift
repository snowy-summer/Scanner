//
//  PreviewController.swift
//  Scanner
//
//  Created by 최승범 on 2024/01/31.
//
import UIKit

protocol PreviewDelegate: AnyObject {
    func changeNavigationTitle()
    func getImageFromScannedImages(at: Int) -> UIImage
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
        view = preview
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isToolbarHidden = false
        navigationController?.navigationBar.isHidden = false
        if !scanServiceProvider.scannedImages.isEmpty {
            preview.updateImageView(image: scanServiceProvider.scannedImages[scanServiceProvider.currentIndex])
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(resource: .background)
        preview.delegate = self
        setupToolBarButton()
        configurePreView()
        changeNavigationTitle()
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
    }
}

//MARK: - configuration

extension PreviewController {
    
    private func configurePreView() {
        preview.updatePageControlPage(numberOfPage: scanServiceProvider.scannedImages.count)
        guard let image = scanServiceProvider.scannedImages.first else { return }
        preview.updateImageView(image: image)
    }
    private func setupToolBarButton() {
        
        let backButton = UIBarButtonItem(image: UIImage(systemName: "arrowshape.backward.fill"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(backAction))
        
        navigationItem.leftBarButtonItem = backButton
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                            target: nil,
                                            action: nil)
        
        let rotateButton = UIBarButtonItem(image: UIImage(systemName: "rotate.right"),
                                           style: .plain,
                                           target: self,
                                           action: #selector(rotateAction))
        rotateButton.tintColor = .black
        
        let deleteButton = UIBarButtonItem(image: UIImage(systemName: "trash.fill"),
                                           style: .plain,
                                           target: self,
                                           action: #selector(deleteAction))
        
        let cropButton = UIBarButtonItem(image: UIImage(systemName: "crop"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(pushRepointViewControllerAction))
        
        let barItems = [ flexibleSpace, deleteButton,
                         flexibleSpace, flexibleSpace, rotateButton, flexibleSpace, flexibleSpace,
                         cropButton, flexibleSpace ]
        
        rotateButton.tintColor = .black
        deleteButton.tintColor = .black
        cropButton.tintColor = .black
        
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
        preview.updateImageView(image: rotatedImage)
    }
    
    @objc private func pushRepointViewControllerAction() {
        if scanServiceProvider.scannedImages.isEmpty {
            cantPushRepointViewControllerAlert()
            return
        }
        scanServiceProvider.currentIndex = preview.pageControl.currentPage
        navigationController?.pushViewController(RepointViewController(scanServiceProvider: scanServiceProvider), animated: true)
    }
    
    @objc private func deleteAction() {
        if !scanServiceProvider.scannedImages.isEmpty {
            scanServiceProvider.deleteImage(at: preview.pageControl.currentPage)
            preview.updatePageControlPage(numberOfPage: scanServiceProvider.scannedImages.count)
            changeNavigationTitle()
            if scanServiceProvider.scannedImages.isEmpty {
                preview.updateImageView(image: UIImage())
                changeNavigationTitle()
                return
            }
            
            if scanServiceProvider.scannedImages.count > preview.pageControl.currentPage {
                preview.updateImageView(image: scanServiceProvider.scannedImages[preview.pageControl.currentPage])
            } else {
                preview.updateImageView(image: scanServiceProvider.scannedImages[preview.pageControl.currentPage - 1])
            }
        }
    }
    
    @objc private func backAction() {
        navigationController?.popViewController(animated: true)
    }
}

//MARK: - PreviewDelegate
extension PreviewController: PreviewDelegate {
    func getImageFromScannedImages(at index: Int) -> UIImage {
        if scanServiceProvider.scannedImages.isEmpty { return UIImage() }
        return scanServiceProvider.scannedImages[index]
    }
    
    func changeNavigationTitle() {
        if scanServiceProvider.scannedImages.isEmpty {
            self.title = "사진없음"
            return
        }
        self.title = "\(preview.pageControl.currentPage + 1) / \(preview.pageControl.numberOfPages)"
    }
}

//MARK: - Alert
extension PreviewController {
    
    private func cantPushRepointViewControllerAlert() {
        let alert = UIAlertController(title: "알림",
                                            message: "편집할 사진이 존재하지 않습니다.",
                                            preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "확인",
                                   style: .default)
        
        alert.addAction(confirm)
        self.present(alert, animated: true, completion: nil)
    }
}
