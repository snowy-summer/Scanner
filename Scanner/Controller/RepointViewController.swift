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
        let image = ScanServiceProvider.shared.readOriginalImage()
        repointView.updateUI(image: image)
    }
    
}
