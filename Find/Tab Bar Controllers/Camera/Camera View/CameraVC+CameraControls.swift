//
//  CameraVC+CameraControls.swift
//  Find
//
//  Created by Zheng on 1/24/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import AVFoundation
import UIKit

extension CameraViewController {
    func getCamera() -> AVCaptureDevice? {
        if let cameraDevice = AVCaptureDevice.default(.builtInDualCamera,
                                                      for: .video, position: .back)
        {
            return cameraDevice
        } else if let cameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                             for: .video, position: .back)
        {
            return cameraDevice
        } else {
            return nil
        }
    }

    func configureCamera() {
        cameraView.session = avSession
        if let cameraDevice = getCamera() {
            self.cameraDevice = cameraDevice
            do {
                let captureDeviceInput = try AVCaptureDeviceInput(device: cameraDevice)
                if avSession.canAddInput(captureDeviceInput) {
                    avSession.addInput(captureDeviceInput)
                }
            } catch {
                return
            }
            avSession.sessionPreset = .photo
            videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "Buffer Queue", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil))
            if avSession.canAddOutput(videoDataOutput) {
                avSession.addOutput(videoDataOutput)
            }
            if avSession.canAddOutput(photoDataOutput) {
                avSession.addOutput(photoDataOutput)
            }
            cameraView.videoPreviewLayer.videoGravity = .resizeAspectFill
            cameraView.videoPreviewLayer.frame = view.layer.bounds
            avSession.startRunning()
        }
    }

    func startSession() {
        if !avSession.isRunning {
            DispatchQueue.global().async {
                self.avSession.startRunning()
            }
        }
    }

    func stopSession() {
        if avSession.isRunning {
            DispatchQueue.global().async {
                self.avSession.stopRunning()
            }
        }
    }
}
