//
//  ViewController.swift
//  Scanner
//
//  Created by 최승범 on 2024/01/31.
//

import UIKit

class ViewController: UIViewController {
    let mainView = MainView()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let cancelButton = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelAction))
        cancelButton.tintColor = .black
        navigationItem.leftBarButtonItem = cancelButton
        
    }
    
   @objc private func cancelAction() {
       
    }
} 

