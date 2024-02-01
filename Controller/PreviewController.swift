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
    override func viewDidLoad() {
        view.backgroundColor = .darkGray
    }
}
