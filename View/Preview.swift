//
//  Preview.swift
//  Scanner
//
//  Created by 최승범 on 2024/02/01.
//

import UIKit

final class Preview: UIView {
    
    private let deleteButton = UIButton()
    private let editButton = UIButton()
    private let finishButton = UIButton()
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureImageView()
        configureFinishButton()
        configureDeleteButton()
        configureEditButton()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("Preview 생성오류")
    }

}

extension Preview {
    private func configureDeleteButton() {
        let buttonSymbol = UIImage.SymbolConfiguration(pointSize: 20, weight: .light)
        deleteButton.setImage(UIImage(systemName: "trash.fill", withConfiguration: buttonSymbol), for: .normal)
        deleteButton.tintColor = .black
        
        self.addSubview(deleteButton)
        
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
    
            deleteButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24),
            deleteButton.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.08),
            deleteButton.widthAnchor.constraint(equalTo: deleteButton.heightAnchor, multiplier: 1.0),
            deleteButton.centerYAnchor.constraint(equalTo: finishButton.centerYAnchor)
        ])
        
    }
    
   private func configureEditButton() {
        let buttonSymbol = UIImage.SymbolConfiguration(pointSize: 20, weight: .light)
        editButton.setImage(UIImage(systemName: "crop", withConfiguration: buttonSymbol), for: .normal)
        editButton.tintColor = .black
        
        self.addSubview(editButton)
        
        editButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            
            editButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24),
            editButton.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.08),
            editButton.widthAnchor.constraint(equalTo: editButton.heightAnchor, multiplier: 1.0),
            editButton.centerYAnchor.constraint(equalTo: finishButton.centerYAnchor)
        ])
    }
    
   private func configureFinishButton() {
        finishButton.setTitle("반시계", for: .normal)
        finishButton.setTitleColor(.black, for: .normal)
        
        self.addSubview(finishButton)
        
        finishButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            finishButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            finishButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 32),
            finishButton.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.07),
            finishButton.widthAnchor.constraint(equalTo: finishButton.heightAnchor, multiplier: 1.0)
        ])
    }
    
    private func configureImageView() {
        self.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.75)
        ])
        
    }
    
}
