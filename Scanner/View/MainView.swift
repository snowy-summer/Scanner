//
//  MainView.swift
//  Scanner
//
//  Created by 최승범 on 2024/01/31.
//

import UIKit
import AVFoundation

protocol MainViewDelegate: AnyObject {
    func pushSaveButton()
    func cantAddCameraViewAction()
    func pushViewControllerAction()
    func appendVideoFrameImage()
}

final class MainView: UIView {
    private(set) var cameraView = UIView()
    private let thumbnailView = UIImageView()
    private let captureButton = UIButton()
    private let saveButton = UIButton()
    private let imageCountView = UIView()
    private let imageCountLabel = UILabel()
    
    private let captureSession = AVCaptureSession()
    private var previewLayer = AVCaptureVideoPreviewLayer()
    private let photoOutput = AVCapturePhotoOutput()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let alphaLayer = CAShapeLayer()
    
    private let mainQueue = DispatchQueue.main
    weak var delegate: MainViewDelegate?
    
    init() {
        super.init(frame: .zero)
        
        configureCameraView()
        configureCaptureButton()
        configureSaveButton()
        configureThumbnailView()
        configureImageCountView()
        configureImageCountLabel()
        
        configureCaptureSassion()
        configurePreviewLayer()
        configurePhotoOutput()
        configureVideoOutput()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Main View 오류")
    }
}

//MARK: - configuration
extension MainView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = cameraView.bounds
    }
    
    private func configureCameraView() {
        self.addSubview(cameraView)
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        cameraView.backgroundColor = .clear
        
        let safeArea = self.safeAreaLayoutGuide
        let cameraViewConstraint = [
            cameraView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            cameraView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            cameraView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            cameraView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.75)
        ]
        
        NSLayoutConstraint.activate(cameraViewConstraint)
    }
    
    private func configureCaptureButton() {
        let buttonSymbol = UIImage.SymbolConfiguration(pointSize: 60, weight: .regular)
        captureButton.setImage(UIImage(systemName: "camera.aperture", withConfiguration: buttonSymbol), for: .normal)
        captureButton.addTarget(self, action: #selector(capture), for: .touchUpInside)
        
        self.addSubview(captureButton)
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        captureButton.tintColor = UIColor.black
        
        let captureButtonConstraint = [
            captureButton.topAnchor.constraint(equalTo: cameraView.bottomAnchor),
            captureButton.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.1),
            captureButton.widthAnchor.constraint(equalTo: captureButton.heightAnchor, multiplier: 1.0),
            captureButton.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ]
        
        NSLayoutConstraint.activate(captureButtonConstraint)
    }
    
    private func configureSaveButton() {
        saveButton.setTitle("저장", for: .normal)
        saveButton.addTarget(self, action: #selector(pushSaveButton), for: .touchUpInside)
        
        self.addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setTitleColor(.black, for: .normal)
        
        let saveButtonConstraint = [
            saveButton.leadingAnchor.constraint(equalTo: captureButton.trailingAnchor, constant: 24),
            saveButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24),
            saveButton.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(saveButtonConstraint)
    }
    
    private func configureThumbnailView() {
        
        self.addSubview(thumbnailView)
        thumbnailView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailView.backgroundColor = .white
        
        let thumbnailViewConstraint = [
            
            thumbnailView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24),
            thumbnailView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.07),
            thumbnailView.widthAnchor.constraint(equalTo: thumbnailView.heightAnchor, multiplier: 1.0),
            thumbnailView.centerYAnchor.constraint(equalTo: saveButton.centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(thumbnailViewConstraint)
        
        thumbnailView.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pushThumbnailView))
        thumbnailView.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    private func configureImageCountView() {
        self.addSubview(imageCountView)
        imageCountView.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        
        imageCountView.translatesAutoresizingMaskIntoConstraints = false
        
        let imageCountViewConstraint = [
            imageCountView.widthAnchor.constraint(equalTo: thumbnailView.widthAnchor, multiplier: 0.4),
            imageCountView.heightAnchor.constraint(equalTo: imageCountView.widthAnchor, multiplier: 1.0)
        ]
        
        NSLayoutConstraint.activate(imageCountViewConstraint)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            NSLayoutConstraint.activate([
                imageCountView.leadingAnchor.constraint(equalTo: thumbnailView.trailingAnchor, constant: -(imageCountView.bounds.width / 2)),
                imageCountView.topAnchor.constraint(equalTo: thumbnailView.topAnchor, constant: -(imageCountView.bounds.width / 2))
            ])
            imageCountView.layer.cornerRadius = imageCountView.bounds.width / 2
        }
        
        imageCountView.isHidden = true
        
    }
    
    private func configureImageCountLabel() {
        imageCountView.addSubview(imageCountLabel)
        imageCountLabel.translatesAutoresizingMaskIntoConstraints = false
        imageCountLabel.textColor = .black
        
        NSLayoutConstraint.activate([
            imageCountLabel.centerXAnchor.constraint(equalTo: imageCountView.centerXAnchor),
            imageCountLabel.centerYAnchor.constraint(equalTo: imageCountView.centerYAnchor),
        ])
    }
    
    private func configureCaptureSassion() {
        do {
            if captureSession.canSetSessionPreset(.high) {
                captureSession.sessionPreset = .high
            } else if captureSession.canSetSessionPreset(.medium) {
                captureSession.sessionPreset = .medium
            } else {
                captureSession.sessionPreset = .low
            }
            
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
            delegate?.cantAddCameraViewAction()
            print(error)
        }
    }
    
    private func configurePreviewLayer() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        cameraView.layer.addSublayer(previewLayer)
        cameraView.layer.addSublayer(alphaLayer)
    }
    
    private func configurePhotoOutput() {
        do {
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            } else {
                throw CameraError.cantAddPhotoOutput
            }
        } catch {
            delegate?.cantAddCameraViewAction()
            print(error)
        }
    }
    
    func configureVideoOutput() {
        do {
            guard let delegate = delegate,
                  let videoDataOutputDelegate = delegate as? AVCaptureVideoDataOutputSampleBufferDelegate else { return }
            
            mainQueue.async { [weak self] in
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    let orientation = windowScene.interfaceOrientation
                    self?.videoOutput.connection(with: .video)?.videoOrientation = AVCaptureVideoOrientation(rawValue: orientation.rawValue) ?? .portrait
                }
            }
            
            videoOutput.setSampleBufferDelegate(videoDataOutputDelegate, queue: DispatchQueue(label: "VideoQueue"))
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            } else {
                throw CameraError.cantAddVideoOutput
            }
        } catch {
            delegate?.cantAddCameraViewAction()
            print(error)
        }
    }
}

//MARK: - objc Button Action
extension MainView {
    
    @objc private func capture() {
//         guard let delegate = delegate,
//               let photoCaptureDelegate = delegate as? AVCapturePhotoCaptureDelegate else { return }
//         let settings = AVCapturePhotoSettings()
//         photoOutput.capturePhoto(with: settings, delegate: photoCaptureDelegate)
        delegate?.appendVideoFrameImage()
        
     }
    
    @objc private func pushThumbnailView() {
        delegate?.pushViewControllerAction()
    }
    
    @objc private func pushSaveButton() {
        delegate?.pushSaveButton()
    }
}

//MARK: - UI Update
extension MainView {
    
    func addCameraViewLayer(subLayer: CALayer) {
        cameraView.layer.addSublayer(subLayer)
    }
    
    func updateThumbnail(image: UIImage, imagesCount: Int) {
        thumbnailView.image = image
        
        if imagesCount > 0 {
            imageCountView.isHidden = false
        } else {
            imageCountView.isHidden = true
        }
        
        imageCountLabel.text = "\(imagesCount)"
    }
    
    func drawRect(cgPoints: [CGPoint]) {
        let outLine = UIBezierPath()
        outLine.move(to: cgPoints[0])
        outLine.addLine(to: cgPoints[1])
        outLine.addLine(to: cgPoints[2])
        outLine.addLine(to: cgPoints[3])
        outLine.close()
        outLine.lineJoinStyle = .round
        
        alphaLayer.path = outLine.cgPath
        alphaLayer.fillColor = UIColor(resource: .sub).withAlphaComponent(0.2).cgColor
        alphaLayer.strokeColor = UIColor(resource: .main).cgColor
        alphaLayer.lineWidth = 4
    }
    
    func captureStartRunning() {
        captureSession.startRunning()
    }
    
    func captureStopRunning() {
        captureSession.stopRunning()
    }
    
    func alpahLayerHiddenOff() {
        if alphaLayer.isHidden == true {
            alphaLayer.isHidden = false
        }
    }
    
    func alpahLayerHiddenOn() {
        if alphaLayer.isHidden == false {
            alphaLayer.isHidden = true
        }
    }
}
