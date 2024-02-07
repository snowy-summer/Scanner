//
//  Preview.swift
//  Scanner
//
//  Created by 최승범 on 2024/02/01.
//

import UIKit

final class Preview: UIView {
    private let imageView = UIImageView()
    private let pageControl = UIPageControl()
    
    var images = [UIImage]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureImageView()
        configurePageControl()
        configureSwipeGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Preview 생성오류")
    }
}

//MARK: - configuration
extension Preview {
    
    private func configureImageView() {
        self.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let safeArea = self.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: safeArea.heightAnchor)
        ])
    }
    
    func configurePageControl() {
        self.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        let safeArea = self.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            pageControl.heightAnchor.constraint(equalToConstant: 40),
            pageControl.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            pageControl.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            pageControl.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
        pageControl.currentPage = 0
        pageControl.isUserInteractionEnabled = true
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.black
    }
    
    func configureSwipeGesture() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(_:)))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(_:)))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.addGestureRecognizer(swipeRight)
        
    }
}

//MARK: - UI Update

extension Preview {
    
    func updateImageView(image: UIImage) {
        imageView.image = image
    }
    
    func updatePageControlPage(numberOfPage: Int) {
        pageControl.numberOfPages = numberOfPage
    }
    
    @objc func respondToSwipeGesture(_ sender: Any) {
        if let swipeGesture = sender as? UISwipeGestureRecognizer{
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.left:
                if pageControl.currentPage <= pageControl.numberOfPages {
                    pageControl.currentPage += 1
                }
                
                imageView.image = images[pageControl.currentPage]
            case UISwipeGestureRecognizer.Direction.right:
                if pageControl.currentPage <= pageControl.numberOfPages && 0 < pageControl.currentPage {
                    pageControl.currentPage -= 1
                }
                
                imageView.image = images[pageControl.currentPage]
            default:
                break
            }
        }
    }
}
