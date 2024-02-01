//
//  ViewController.swift
//  Scanner
//
//  Created by 최승범 on 2024/01/31.
//

import UIKit
import CoreImage
import AVFoundation

final class ViewController: UIViewController {
    private var mainView: MainView!
    
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var photoOutput: AVCapturePhotoOutput!
  
    override func loadView() {
        mainView = MainView(mainViewdelegate: self)
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray
        
        let cancelButton = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelAction))
        cancelButton.tintColor = .white
        navigationItem.leftBarButtonItem = cancelButton
        navigationController?.navigationBar.tintColor = .black

        configureCaptureSassion()
        configurePreviewLayer()
        configurePhotoOutput()
        
        // 캡처 세션 시작
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

    }
}

extension ViewController {
    
    func detectRectangleAndCorrectPerspective(image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        // Detector 생성
        let options: [String: Any] = [
            CIDetectorAccuracy: CIDetectorAccuracyHigh,
            CIDetectorMinFeatureSize: NSNumber(floatLiteral: 0.2)
        ]
        guard let detector = CIDetector(ofType: CIDetectorTypeRectangle,
                                        context: nil,
                                        options: options) else { return nil }
        
        // Detect rectangles
        let features = detector.features(in: ciImage)
        guard let rectangleFeature = features.first as? CIRectangleFeature else { return nil }
        
        // Correct perspective
        let perspectiveCorrection = CIFilter(name: "CIPerspectiveCorrection")
        perspectiveCorrection?.setValue(CIVector(cgPoint: rectangleFeature.topLeft), forKey: "inputTopLeft")
        perspectiveCorrection?.setValue(CIVector(cgPoint: rectangleFeature.topRight), forKey: "inputTopRight")
        perspectiveCorrection?.setValue(CIVector(cgPoint: rectangleFeature.bottomRight), forKey: "inputBottomRight")
        perspectiveCorrection?.setValue(CIVector(cgPoint: rectangleFeature.bottomLeft), forKey: "inputBottomLeft")
        perspectiveCorrection?.setValue(ciImage, forKey: kCIInputImageKey)
        
        guard let outputImage = perspectiveCorrection?.outputImage else { return nil }
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
    
    //MARK: - AVFoundation configuration
    private func configureCaptureSassion() {
        // AVCaptureSession 생성
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        // 후면 카메라를 가져옴
        guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("카메라를 사용할 수 없습니다.")
            return
        }
        
        // 후면 카메라를 입력으로 사용
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
        // 프리뷰 레이어 생성
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

extension ViewController: MainViewDelegate {
    func pushSaveButton() {
        navigationController?.pushViewController(PreviewController(), animated: true)
    }
    
    func pushCaptureButton() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
}

extension ViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        let originalImage = UIImage(data: imageData)
        
    }
    
}
