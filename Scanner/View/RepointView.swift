//
//  RepointView.swift
//  Scanner
//
//  Created by 최승범 on 2024/02/01.
//

import UIKit

final class RepointView: UIView {
    
    private let imageView = UIImageView()
    
    init() {
        super.init(frame: .zero)
        configureImageView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("RepointView 생성 에러")
    }
}

//MARK: - configuration
extension RepointView {
    private func configureImageView() {
        self.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .white
        
        let safeArea = self.safeAreaLayoutGuide
        let cameraViewConstraint = [
            imageView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(cameraViewConstraint)
    }
}


extension RepointView {
    func updateUI(image: UIImage) {
        imageView.image = image
    }

}

