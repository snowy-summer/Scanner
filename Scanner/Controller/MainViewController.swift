//
//  MainViewController.swift
//  Scanner
//
//  Created by 최승범 on 2024/01/31.
//

import UIKit
import AVFoundation

final class MainViewController: UIViewController {
    private var mainView = MainView()
    
    private let scanServiceProvider = ScanServiceProvider.shared
    private var beforePoints = [CGPoint]()
    private var afterPoints = [CGPoint]()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
        mainView.delegate = self
        mainView.configureVideoOutput()
        
        let cancelButton = UIBarButtonItem(title: "취소",
                                           style: .plain,
                                           target: self,
                                           action: #selector(cancelAction))
        cancelButton.tintColor = .white
        navigationItem.leftBarButtonItem = cancelButton
        navigationController?.navigationBar.tintColor = .black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isToolbarHidden = true
        //TODO: 카메라 전환이 부드럽지 못함
        
        DispatchQueue.global().async { [weak self] in
            self?.mainView.captureStartRunning()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        mainView.captureStopRunning()
    }
    
    @objc private func cancelAction() {
        ScanServiceProvider.shared.clearImages()
        mainView.updateThumbnail(image: UIImage(), imagesCount: 0)
    }
    
    func drawRectOnCameraPreview(image: UIImage) {
        do {
            let viewSize = mainView.cameraView.bounds.size
            afterPoints = try scanServiceProvider.getDetectedRectanglePoint(image: image, viewSize: viewSize)
            if beforePoints.isEmpty {
                beforePoints = afterPoints
            }
            
            for i in 0...3 {
                if beforePoints[i].x + 8 < afterPoints[i].x || beforePoints[i].x - 8 > afterPoints[i].x {
                    beforePoints[i].x = afterPoints[i].x
                }
                if beforePoints[i].y + 8 < afterPoints[i].y || beforePoints[i].y - 8 > afterPoints[i].y {
                    beforePoints[i].y = afterPoints[i].y
                }
            }
            
            mainView.drawRect(cgPoints: beforePoints)
            
        } catch {
            print(error)
        }
    }
}

//MARK: - MainViewDelegate
extension MainViewController: MainViewDelegate {
    
    func pushSaveButton() {
        navigationController?.pushViewController(PreviewController(), animated: true)
    }
    
    func getCountOfImages() -> Int {
        return scanServiceProvider.imagesCount()
    }
    
    func appendOriginalImage(image: UIImage) {
        do{
            try scanServiceProvider.getImage(image: image)
        } catch {
            print(error)
        }
    }
}

extension MainViewController: AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let imageData = photo.fileDataRepresentation() else { return }
        guard let originalImage = UIImage(data: imageData) else { return }
        
        appendOriginalImage(image: originalImage)
        mainView.updateThumbnail(image: originalImage, imagesCount: scanServiceProvider.imagesCount())
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let image = UIImage(ciImage: ciImage)
        
        DispatchQueue.main.async { [weak self] in
            self?.drawRectOnCameraPreview(image: image)
            self?.mainView.layoutSubviews()
        }
    }
    
}
