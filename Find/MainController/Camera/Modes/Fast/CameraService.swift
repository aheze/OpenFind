////
////  CameraService.swift
////  Find
////
////  Created by Andrew on 1/18/20.
////  Copyright © 2020 Andrew. All rights reserved.
////
//
//import UIKit
//import AVFoundation
//import Vision
//
//class CameraService: NSObject {
//
////    private weak var previewView: UIView?
////    private(set) var cameraIsReadyToUse = false
////    private let session = AVCaptureSession()
////    private weak var previewLayer: AVCaptureVideoPreviewLayer?
////    private lazy var sequenceHandler = VNSequenceRequestHandler()
////    private lazy var capturePhotoOutput = AVCapturePhotoOutput()
////    private lazy var dataOutputQueue = DispatchQueue(label: "FaceDetectionService",
////                                                     qos: .userInitiated, attributes: [],
////                                                     autoreleaseFrequency: .workItem)
//    private var captureCompletionBlock: ((UIImage) -> Void)?
//    private var preparingCompletionHandler: ((Bool) -> Void)?
//    private var snapshotImageOrientation = UIImage.Orientation.upMirrored
//
////    private var cameraPosition = AVCaptureDevice.Position.front {
////        didSet {
////            switch cameraPosition {
////                case .front: snapshotImageOrientation = .upMirrored
////                case .unspecified, .back: fallthrough
////                @unknown default: snapshotImageOrientation = .up
////            }
////        }
////    }
////    func prepare(previewView: UIView,
////                 cameraPosition: AVCaptureDevice.Position,
////                 completion: ((Bool) -> Void)?) {
////        self.previewView = previewView
////        self.preparingCompletionHandler = completion
////        self.cameraPosition = cameraPosition
////        checkCameraAccess { allowed in
////            if allowed { self.setup() }
////            completion?(allowed)
////            self.preparingCompletionHandler = nil
////        }
////    }
//
////    private func setup() { configureCaptureSession() }
////    func start() { if cameraIsReadyToUse { session.startRunning() } }
////    func stop() { session.stopRunning() }
//}
//
//extension CameraService {
//
//    private func askUserForCameraPermission(_ completion:  ((Bool) -> Void)?) {
//        AVCaptureDevice.requestAccess(for: AVMediaType.video) { (allowedAccess) -> Void in
//            DispatchQueue.main.async { completion?(allowedAccess) }
//        }
//    }
//
//    private func checkCameraAccess(completion: ((Bool) -> Void)?) {
//        askUserForCameraPermission { [weak self] allowed in
//            guard let self = self, let completion = completion else { return }
//            self.cameraIsReadyToUse = allowed
//            if allowed {
//                completion(true)
//            } else {
//                self.showDisabledCameraAlert(completion: completion)
//            }
//        }
//    }
//
//    private func configureCaptureSession() {
//        guard let previewView = previewView else { return }
//        // Define the capture device we want to use
//
//        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraPosition) else {
//            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "No front camera available"])
//            show(error: error)
//            return
//        }
//
//        // Connect the camera to the capture session input
//        do {
//
//            try camera.lockForConfiguration()
//            defer { camera.unlockForConfiguration() }
//
//            if camera.isFocusModeSupported(.continuousAutoFocus) {
//                camera.focusMode = .continuousAutoFocus
//            }
//
//            if camera.isExposureModeSupported(.continuousAutoExposure) {
//                camera.exposureMode = .continuousAutoExposure
//            }
//
//            let cameraInput = try AVCaptureDeviceInput(device: camera)
//            session.addInput(cameraInput)
//
//        } catch {
//            show(error: error as NSError)
//            return
//        }
//
//        // Create the video data output
//        let videoOutput = AVCaptureVideoDataOutput()
//        videoOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
//        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
//
//        // Add the video output to the capture session
//        session.addOutput(videoOutput)
//
//        let videoConnection = videoOutput.connection(with: .video)
//        videoConnection?.videoOrientation = .portrait
//
//        // Configure the preview layer
//        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
//        previewLayer.videoGravity = .resizeAspectFill
//        previewLayer.frame = previewView.bounds
//        previewView.layer.insertSublayer(previewLayer, at: 0)
//        self.previewLayer = previewLayer
//    }
//}
//
//extension CameraService: AVCaptureVideoDataOutputSampleBufferDelegate {
//    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        guard   captureCompletionBlock != nil,
//                let outputImage = UIImage(sampleBuffer: sampleBuffer, orientation: snapshotImageOrientation) else { return }
//        DispatchQueue.main.async { [weak self] in
//            guard let self = self else { return }
//            if let captureCompletionBlock = self.captureCompletionBlock {
//                captureCompletionBlock(outputImage)
//                AudioServicesPlayAlertSound(SystemSoundID(1108))
//            }
//            self.captureCompletionBlock = nil
//        }
//    }
//}
//
//
//extension CameraService: AVCapturePhotoCaptureDelegate {
//    func capturePhoto(completion: ((UIImage) -> Void)?) { captureCompletionBlock = completion }
//}
