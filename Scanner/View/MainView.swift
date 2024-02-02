//
//  MainView.swift
//  Scanner
//
//  Created by 최승범 on 2024/01/31.
//

import UIKit
import AVFoundation

final class MainView: UIView {
    private let cameraView = UIView()
    private let thumbnailView = UIImageView()
    private let captureButton = UIButton()
    private let saveButton = UIButton()
    private let imageCountView = UIView()
    private let imageCountLabel = UILabel()
    
    weak var delegate: MainViewDelegate?
    
    init() {
        super.init(frame: .zero)
        
        configureCameraView()
        configureCaptureButton()
        configureSaveButton()
        configureThumbnailView()
        configureImageCountView()
        configureImageCountLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Main View 오류")
    }
}

//MARK: - configuration
extension MainView {
    private func configureCameraView() {
        self.addSubview(cameraView)
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        cameraView.backgroundColor = .clear
        
        let safeArea = self.safeAreaLayoutGuide
        let cameraViewConstraint = [
            cameraView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            cameraView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            cameraView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            cameraView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.75)
//            cameraView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(cameraViewConstraint)
    }
    
    private func configureCaptureButton() {
        let buttonSymbol = UIImage.SymbolConfiguration(pointSize: 60, weight: .regular)
        captureButton.setImage(UIImage(systemName: "camera.aperture", withConfiguration: buttonSymbol), for: .normal)
        captureButton.addTarget(self, action: #selector(pushCaptureButton), for: .touchUpInside)
        captureButton.tintColor = .white
        
        self.addSubview(captureButton)
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        
        let captureButtonConstraint = [
            captureButton.topAnchor.constraint(equalTo: cameraView.bottomAnchor),
            captureButton.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.1),
            captureButton.widthAnchor.constraint(equalTo: captureButton.heightAnchor, multiplier: 1.0),
            captureButton.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ]
        
        NSLayoutConstraint.activate(captureButtonConstraint)
    }
    
    private func configureSaveButton() {
        saveButton.setTitle("저장", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.addTarget(self, action: #selector(pushSaveButton), for: .touchUpInside)
        
        self.addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        let saveButtonConstraint = [
            saveButton.leadingAnchor.constraint(equalTo: captureButton.trailingAnchor, constant: 24),
            saveButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24),
            saveButton.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(saveButtonConstraint)
    }
    
    private func configureThumbnailView() {
        
        self.addSubview(thumbnailView)
        thumbnailView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailView.backgroundColor = .white
        
        let thumbnailViewConstraint = [
            
            thumbnailView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24),
            thumbnailView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.07),
            thumbnailView.widthAnchor.constraint(equalTo: thumbnailView.heightAnchor, multiplier: 1.0),
            thumbnailView.centerYAnchor.constraint(equalTo: saveButton.centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(thumbnailViewConstraint)
        
        thumbnailView.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pushSaveButton))
        thumbnailView.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    private func configureImageCountView() {
        self.addSubview(imageCountView)
        imageCountView.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        
        imageCountView.translatesAutoresizingMaskIntoConstraints = false
        
        let imageCountViewConstraint = [
            imageCountView.widthAnchor.constraint(equalTo: thumbnailView.widthAnchor, multiplier: 0.4),
            imageCountView.heightAnchor.constraint(equalTo: imageCountView.widthAnchor, multiplier: 1.0)
        ]
        
        NSLayoutConstraint.activate(imageCountViewConstraint)
        DispatchQueue.main.async { [weak self] in
            NSLayoutConstraint.activate([
                self!.imageCountView.leadingAnchor.constraint(equalTo: self!.thumbnailView.trailingAnchor, constant: -(self!.imageCountView.bounds.width / 2)),
                self!.imageCountView.topAnchor.constraint(equalTo: self!.thumbnailView.topAnchor, constant: -(self!.imageCountView.bounds.width / 2))
            ])
            self!.imageCountView.layer.cornerRadius = self!.imageCountView.bounds.width / 2
        }
        
        imageCountView.isHidden = true
        
    }
    
    private func configureImageCountLabel() {
        imageCountView.addSubview(imageCountLabel)
        imageCountLabel.translatesAutoresizingMaskIntoConstraints = false
        imageCountLabel.textColor = .black
        
        NSLayoutConstraint.activate([
            imageCountLabel.centerXAnchor.constraint(equalTo: imageCountView.centerXAnchor),
            imageCountLabel.centerYAnchor.constraint(equalTo: imageCountView.centerYAnchor),
        ])
    }
}

extension MainView {
    func addCameraViewLayer(subLayer: CALayer) {
        cameraView.layer.addSublayer(subLayer)
    }
    
    func cameraViewBounds() -> CGRect{
        return cameraView.bounds
    }
    
    func updateThumbnail(image: UIImage, imagesCount: Int) {
        thumbnailView.image = image
        
        if imagesCount > 0 {
            imageCountView.isHidden = false
        } else {
            imageCountView.isHidden = true
        }
        
        imageCountLabel.text = "\(imagesCount)"
    }
}

//MARK: - objc Button Action
extension MainView {
    @objc private func pushCaptureButton() {
        delegate?.pushCaptureButton()
    }
    
    @objc private func pushSaveButton() {
        delegate?.pushSaveButton()
    }
}
