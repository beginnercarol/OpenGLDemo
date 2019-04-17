//
//  CACamViewController.swift
//  CACamProcessor
//
//  Created by Carol on 2019/4/12.
//  Copyright © 2019 Carol. All rights reserved.
//

import UIKit
import AVFoundation
import CoreImage

class CACamViewController: UIViewController {
    enum SetupResult {
        case Success
        case NotDetermined
        case Failed
    }
    var session = AVCaptureSession()
    var sessionQueue = DispatchQueue(label: "sessionQueu")
    var previewView: CACamPreview!
    var videoDevice: AVCaptureDevice!
    var videoDeviceInput: AVCaptureDeviceInput!
    var videoDeviceOutput: AVCaptureVideoDataOutput!
    var capButton: UIButton!
    var setupResult = SetupResult.Failed
    var toolbar: UIToolbar!
    
    var faceDetector: CIDetector? = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyLow]) ?? nil
    
    var caOpenGlView: CACamOpenGLView!
    private var context: EAGLContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.previewView = CACamPreview(frame: self.view.frame)
//        view.addSubview(self.previewView)
        self.caOpenGlView = CACamOpenGLView(frame: self.view.frame)
        view.addSubview(caOpenGlView)
        toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: toolbarHeight))
        self.view.addSubview(toolbar)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        let vToolbarVFLString = "V:|->=0-[toolbar(==toolbarHeight)]-==0-|"
        let hToolbarVFLString = "H:|-==0-[toolbar]-==0-|"
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: vToolbarVFLString, options: [.alignAllBottom], metrics: ["toolbarHeight": self.toolbarHeight], views: ["toolbar": self.toolbar]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: hToolbarVFLString, options: [.alignAllBottom], metrics: nil, views: ["toolbar": self.toolbar]))
        let capButtonBarItem = UIBarButtonItem(title: "Capture", style: .plain, target: self, action: #selector(takePhoto(_:)))
        toolbar.setItems([capButtonBarItem], animated: true)
        capButton = UIButton(type: .system)
        capButton.setTitle("Capture", for: .normal)

        previewView.session = session
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.setupResult = .Success
        case .notDetermined:
            sessionQueue.suspend();
            AVCaptureDevice.requestAccess(for: .video) { (success) in
                if (success) {
                    self.setupResult = .NotDetermined
                }
                self.sessionQueue.resume()
            }
        default:
            self.setupResult = .Failed
        }
        NSLog("\(CAOpenCVWrapper.openCVVersionString())")
        sessionQueue.async {
            self.configureSession()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sessionQueue.async {
            switch self.setupResult {
            case .Success:
                self.session.startRunning()
            case .Failed:
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "CACam", message: "CACam request access to camera", preferredStyle: .actionSheet)
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    let settingAction = UIAlertAction(title: "Settings", style: .default, handler: { (action) in
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                    })
                    alertController.addAction(settingAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            case .NotDetermined:
                break
            }
        }
    }
    
    
    
    func configureSession() {
        if setupResult == .Success {
            session.beginConfiguration()
            session.sessionPreset =  .photo
            
            guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                self.setupResult = .Failed
                return
            }

            self.videoDevice = captureDevice
            if let devideInput = try? AVCaptureDeviceInput.init(device: captureDevice) {
                if session.canAddInput(devideInput) {
                    session.addInput(devideInput)
                    self.videoDeviceInput = devideInput
                    DispatchQueue.main.async {
//                        self.previewView.videoPreviewLayer.connection?.videoOrientation = .portrait
                        self.videoDeviceOutput.connection(with: .video)?.videoOrientation = .portrait
                    }
                }
            }
            let deviceOutput = AVCaptureVideoDataOutput()
            if session.canAddOutput(deviceOutput) {
                session.addOutput(deviceOutput)
                self.videoDeviceOutput = deviceOutput
                self.videoDeviceOutput.alwaysDiscardsLateVideoFrames = true
            } else {
                self.setupResult = .Failed
            }
//            do {
//                try self.videoDevice.lockForConfiguration()
//                if self.videoDevice.isExposureModeSupported(.custom) {
//                    self.videoDevice.setExposureModeCustom(duration: self.videoDevice.activeFormat.minExposureDuration, iso: self.videoDevice.activeFormat.maxISO, completionHandler: nil)
//                }
//            } catch {
//                NSLog("Error: \(error)")
//            }
            
            session.commitConfiguration()
        }
    }
    
    //MARK: - Button
    @objc func takePhoto(_ sender: UIButton) {
        var captureSetting = AVCapturePhotoSettings()
        
//        self.videoDeviceOutput.capturePhoto(with: captureSetting, delegate: self)
    }
    
    
}

extension CACamViewController {
    struct SizeRatio {
        static let toolbarHeightRatio: CGFloat = 0.15
    }
    var toolbarHeight: CGFloat {
        return SizeRatio.toolbarHeightRatio * self.view.frame.height
    }
}

extension CACamViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
           let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let featureArray = faceDetector?.features(in: ciImage, options: nil)
        }
        
        
    }
}



extension CACamViewController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_: AVCapturePhotoOutput, willBeginCaptureFor: AVCaptureResolvedPhotoSettings) {
        
    }
    
    func photoOutput(_: AVCapturePhotoOutput, willCapturePhotoFor: AVCaptureResolvedPhotoSettings) {
        
    }
    
    func photoOutput(_: AVCapturePhotoOutput, didCapturePhotoFor: AVCaptureResolvedPhotoSettings) {
        
    }
    
    func photoOutput(_: AVCapturePhotoOutput, didFinishCaptureFor: AVCaptureResolvedPhotoSettings, error: Error?) {
        
    }
    
    func photoOutput(_: AVCapturePhotoOutput, didFinishProcessingPhoto: AVCapturePhoto, error: Error?) {
        
    }
    
    func photoOutput(_: AVCapturePhotoOutput, didFinishRecordingLivePhotoMovieForEventualFileAt: URL, resolvedSettings: AVCaptureResolvedPhotoSettings) {
        
    }
    
    func photoOutput(_: AVCapturePhotoOutput, didFinishProcessingLivePhotoToMovieFileAt: URL, duration: CMTime, photoDisplayTime: CMTime, resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        
    }
    

}


