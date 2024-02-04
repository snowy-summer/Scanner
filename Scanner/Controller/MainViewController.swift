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
    private let alphaLayer = CAShapeLayer()
    private let scanServiceProvider = ScanServiceProvider.shared
    
    override func loadView() {
        view = mainView
    }
    
    override func viewWillLayoutSubviews() {
        previewLayer.frame = mainView.cameraViewBounds()
        alphaLayer.removeFromSuperlayer()
        previewLayer.addSublayer(alphaLayer)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
        mainView.delegate = self
        
        let cancelButton = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelAction))
        cancelButton.tintColor = .white
        navigationItem.leftBarButtonItem = cancelButton
        navigationController?.navigationBar.tintColor = .black
        
        configureCaptureSassion()
        configurePreviewLayer()
        configurePhotoOutput()
        configureVideoOutput()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isToolbarHidden = true
        //TODO: 카메라 전환이 부드럽지 못함
        DispatchQueue.global().async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        captureSession.stopRunning()
    }
    
    @objc private func cancelAction() {
        ScanServiceProvider.shared.clearImages()
        mainView.updateThumbnail(image: UIImage(), imagesCount: 0)
    }
}
//MARK: -
extension MainViewController {
    func drawRect(image: UIImage) {
        do {
            let viewSize = mainView.cameraViewBounds().size
            let points = try scanServiceProvider.getDetectedRectanglePoint(image: image, viewSize: viewSize)
            
            drawRect(cgPoints: points)
            
        } catch {
            print(error)
        }
    }

    private func drawRect(cgPoints: [CGPoint]) {
        let outLine = UIBezierPath()
        outLine.move(to: cgPoints[0])
        outLine.addLine(to: cgPoints[1])
        outLine.addLine(to: cgPoints[2])
        outLine.addLine(to: cgPoints[3])
        outLine.addLine(to: cgPoints[0])
        
        alphaLayer.path = outLine.cgPath
        alphaLayer.fillColor = UIColor(resource: .sub).withAlphaComponent(0.2).cgColor
        alphaLayer.strokeColor = UIColor(resource: .main).cgColor
        alphaLayer.lineWidth = 4
    }
    
    
}

//MARK: - MainViewDelegate
extension MainViewController: MainViewDelegate {
    
    func pushSaveButton() {
        navigationController?.pushViewController(PreviewController(), animated: true)
    }
    
    func pushCaptureButton() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

//MARK: - AVFoundation configuration
extension MainViewController {
    
    private func configureCaptureSassion() {
        do {
            captureSession = AVCaptureSession()
            captureSession.sessionPreset = .high
            
            guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                           for: .video,
                                                           position: .back) else {
                throw CameraError.cantAddBackCamera
            }
            
            let input = try AVCaptureDeviceInput(device: backCamera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            } else {
                throw CameraError.cantAddDeviceInput
            }
        } catch {
            print(error)
        }
    }
    
    private func configurePreviewLayer() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        mainView.addCameraViewLayer(subLayer: previewLayer)
    }
    
    private func configurePhotoOutput() {
        do {
            photoOutput = AVCapturePhotoOutput()
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            } else {
                throw CameraError.cantAddPhotoOutput
            }
        } catch {
            print(error)
        }
    }
    
    private func configureVideoOutput() {
        do {
            let output = AVCaptureVideoDataOutput()
            output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "1e"))
            
            if captureSession.canAddOutput(output) {
                captureSession.addOutput(output)
            } else {
                throw CameraError.cantAddVideoOutput
            }
        } catch {
            print(error)
        }
    }
}

//MARK: - AVCapturePhotoCaptureDelegate
extension MainViewController: AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        do {
            guard let imageData = photo.fileDataRepresentation() else { return }
            let originalImage = UIImage(data: imageData)
            
            try scanServiceProvider.getImage(image: originalImage!)
            mainView.updateThumbnail(image: originalImage!, imagesCount:  ScanServiceProvider.shared.imagesCount())
            
        } catch {
            print(error)
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let image = UIImage(ciImage: ciImage)
        
        DispatchQueue.main.async { [weak self] in
            self?.drawRect(image: image)
            self?.viewWillLayoutSubviews()
        }
    }
}

