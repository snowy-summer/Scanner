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
    
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var photoOutput: AVCapturePhotoOutput!
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray
        mainView.delegate = self
        
        let cancelButton = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelAction))
        cancelButton.tintColor = .white
        navigationItem.leftBarButtonItem = cancelButton
        navigationController?.navigationBar.tintColor = .black
        
        configureCaptureSassion()
        configurePreviewLayer()
        configurePhotoOutput()
        
        Thread.detachNewThread { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    override func viewWillLayoutSubviews() {
        previewLayer.frame = mainView.cameraViewBounds()
    }
    
    deinit {
        captureSession.stopRunning()
    }
    
    @objc private func cancelAction() {
        ScanServiceProvider.shared.clearImages()
        mainView.updateThumbnail(image: UIImage(), imagesCount: 0)
    }
}
//MARK: - AVFoundation configuration
extension MainViewController {
    private func configureCaptureSassion() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("카메라를 사용할 수 없습니다.")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            } else {
                print("입력을 추가할 수 없습니다.")
                return
            }
        } catch {
            print("카메라 입력을 생성할 수 없습니다: \(error)")
            return
        }
    }
    
    private func configurePreviewLayer() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        mainView.addCameraViewLayer(subLayer: previewLayer)
    }
    
    private func configurePhotoOutput() {
        photoOutput = AVCapturePhotoOutput()
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        } else {
            print("출력을 추가할 수 없습니다.")
            return
        }
    }
}

extension MainViewController: MainViewDelegate {
    func pushSaveButton() {
        navigationController?.pushViewController(PreviewController(), animated: true)
    }
    
    func pushCaptureButton() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
}

extension MainViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        let originalImage = UIImage(data: imageData)
        
        ScanServiceProvider.shared.getImage(image: originalImage!)
        mainView.updateThumbnail(image: originalImage!, imagesCount:  ScanServiceProvider.shared.imagesCount())
    }
    
}
