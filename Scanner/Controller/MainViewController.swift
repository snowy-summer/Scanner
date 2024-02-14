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
    
    private let scanServiceProvider = ScanServiceProvider()
    private var beforePoints = [CGPoint]()
    private var afterPoints = [CGPoint]()
    private var frameImage = UIImage()
    
    private let mainQueue = DispatchQueue.main
    private let cameraQueue = DispatchQueue.global()
    
    
    override func loadView() {
        super.loadView()
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(resource: .background)
        mainView.delegate = self
        mainView.configureVideoOutput()
        configureNavigationBar()
        requestCameraAccess()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isToolbarHidden = true
        
        cameraQueue.async { [weak self] in
            self?.mainView.captureStartRunning()
        }
        
        guard let thumbnail = scanServiceProvider.originalImages.last else {
            mainView.updateThumbnail(image: UIImage(), imagesCount: 0)
            return
        }
        
        mainView.updateThumbnail(image: thumbnail, imagesCount: scanServiceProvider.originalImages.count)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        mainView.captureStopRunning()
    }
}

extension MainViewController {
    
    private func configureNavigationBar() {
        let captureTypeButton = UIBarButtonItem(title: "자동/수동",
                                                style: .plain,
                                                target: self,
                                                action: #selector(turnOnAutoTypeAction))
        
        let cancelButton = UIBarButtonItem(title: "취소",
                                           style: .plain,
                                           target: self,
                                           action: #selector(cancelAction))
        
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = captureTypeButton
        navigationController?.navigationBar.tintColor = .black
    }
    
    @objc private func cancelAction() {
        scanServiceProvider.clearImages()
        mainView.updateThumbnail(image: UIImage(), imagesCount: 0)
    }
    
    @objc private func turnOnAutoTypeAction() {
   
    }
    
    private func requestCameraAccess() {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { [weak self] (result) in
            if !result {
                self?.mainQueue.async {
                    self?.requestCameraAccessAlert()
                }
            }
        })
    }
    
    private func requestCameraAccessAlert() {
        let cameraAlert = UIAlertController(title: "알림",
                                            message: "카메라를 이용하기 위해서 카메라의 사용권한이 필요합니다.",
                                            preferredStyle: .alert)
        
        let setting = UIAlertAction(title: "설정",
                                    style: .default) { (UIAlertAction) in
            guard let appSetting = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(appSetting)
        }
        
        let confirm = UIAlertAction(title: "확인",
                                   style: .default)
        
        cameraAlert.addAction(setting)
        cameraAlert.addAction(confirm)
        self.present(cameraAlert, animated: true, completion: nil)
    }
    
    private func requestPhotoLibraryAcess() {
        
        let scannedImages = scanServiceProvider.originalImages
        
        for i in scannedImages {
            UIImageWriteToSavedPhotosAlbum(i, nil, nil, nil)
        }
    }

    private func requestPhotoLibraryAccessAlert() {
        let cameraAlert = UIAlertController(title: "알림",
                                            message: "사진을 저장하기 위해서 앨범의 사용권한이 필요합니다.",
                                            preferredStyle: .alert)
        
        
        let setting = UIAlertAction(title: "설정",
                                    style: .default)
        
        let confirm = UIAlertAction(title: "확인",
                                    style: .default)
        
        cameraAlert.addAction(setting)
        cameraAlert.addAction(confirm)
        self.present(cameraAlert, animated: true, completion: nil)
    }
    
    private func drawRectOnCameraPreview(image: UIImage) {
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
            mainView.alpahLayerHiddenOff()
            mainView.drawRect(cgPoints: beforePoints)
            
        } catch {
            if error as? DetectorError == DetectorError.failToDetectRectangle {
                mainView.alpahLayerHiddenOn()
            }
            print(error)
        }
    }
    
    private func appendOriginalImage(image: UIImage) {
        do{
            try scanServiceProvider.appendScannedImage(image: image)
        } catch {
            scanServiceProvider.appendOriginalImage(image: image)
            print(error)
        }
    }
}

//MARK: - MainViewDelegate
extension MainViewController: MainViewDelegate {
    
    func pushSaveButton() {
        requestPhotoLibraryAcess()
    }
    
    func pushViewControllerAction() {
        navigationController?.pushViewController(PreviewController(scanServiceProvider: scanServiceProvider), animated: true)
    }
    
    func cantAddCameraViewAction() {
        print("cantAddCameraView")
    }
    
    func appendVideoFrameImage() {
        appendOriginalImage(image: frameImage)
        mainView.updateThumbnail(image: frameImage, imagesCount: scanServiceProvider.originalImages.count)
    }
}

//MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension MainViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let image = UIImage(ciImage: ciImage)
        frameImage = image
        
        mainQueue.async { [weak self] in
            self?.drawRectOnCameraPreview(image: image)
            self?.mainView.layoutSubviews()
        }
    }
}
