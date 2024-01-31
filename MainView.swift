//
//  MainView.swift
//  Scanner
//
//  Created by 최승범 on 2024/01/31.
//

import UIKit

final class MainView: UIView {
    let cameraView: UIImageView = UIImageView()
    private let captureButton: UIButton = UIButton()
    private let saveButton: UIButton = UIButton()
    private let thumbnailView: UIImageView = UIImageView()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
    
        
        configureCameraView()
        configureCaptureButton()
        configureSaveButton()
        configureThumbnailView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Main View 오류")
    }
    
    
    
    
}

//MARK: - constraint configure
extension MainView {
    
    func configureCameraView() {
        self.addSubview(cameraView)
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        cameraView.backgroundColor = .white
        
        let safeArea = self.safeAreaLayoutGuide
        let cameraViewConstraint = [
            cameraView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            cameraView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            cameraView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            cameraView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.7)
        ]
        
        NSLayoutConstraint.activate(cameraViewConstraint)
    }
    
    func configureCaptureButton() {
        let buttonSymbol = UIImage.SymbolConfiguration(pointSize: 60, weight: .light)
        captureButton.setImage(UIImage(systemName: "camera.circle.fill", withConfiguration: buttonSymbol), for: .normal)
    
        self.addSubview(captureButton)
        captureButton.translatesAutoresizingMaskIntoConstraints = false
    
        let captureButtonConstraint = [
            captureButton.topAnchor.constraint(equalTo: cameraView.bottomAnchor, constant: 16),
            captureButton.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.1),
            captureButton.widthAnchor.constraint(equalTo: captureButton.heightAnchor, multiplier: 1.0),
            captureButton.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ]
        
        NSLayoutConstraint.activate(captureButtonConstraint)
    }
    
    func configureSaveButton() {

        saveButton.setTitle("저장", for: .normal)
        saveButton.setTitleColor(.black, for: .normal)
        
        self.addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
    
        let saveButtonConstraint = [
            saveButton.leadingAnchor.constraint(equalTo: captureButton.trailingAnchor, constant: 24),
            saveButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 24),
            saveButton.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(saveButtonConstraint)
    }
    
    func configureThumbnailView() {
        thumbnailView.image = UIImage(named: "ipad")
        
        self.addSubview(thumbnailView)
        thumbnailView.translatesAutoresizingMaskIntoConstraints = false
    
        let thumbnailViewConstraint = [
            
            thumbnailView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            thumbnailView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.07),
            thumbnailView.widthAnchor.constraint(equalTo: thumbnailView.heightAnchor, multiplier: 1.0),
            thumbnailView.centerYAnchor.constraint(equalTo: saveButton.centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(thumbnailViewConstraint)
    }
}

