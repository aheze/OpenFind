//
//  CameraVC+CameraSetup.swift
//  FindAppClip1
//
//  Created by Zheng on 3/18/21.
//

import UIKit
import AVFoundation

extension CameraViewController {
    func configureCamera() {
        if let cameraDevice = getCamera() {
            self.cameraDevice = cameraDevice
            do {
                let captureDeviceInput = try AVCaptureDeviceInput(device: cameraDevice)
                if avSession.canAddInput(captureDeviceInput) {
                    avSession.addInput(captureDeviceInput)
                }
            }
            catch {

                return
            }
            avSession.sessionPreset = .photo
            videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "Buffer Queue", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil))
            if avSession.canAddOutput(videoDataOutput) {
                avSession.addOutput(videoDataOutput)
            }
            
            DispatchQueue.main.async {
                
                self.cameraView.session = self.avSession
                let newBounds = self.view.layer.bounds
                self.cameraView.videoPreviewLayer.bounds = newBounds
                self.cameraView.videoPreviewLayer.position = CGPoint(x: newBounds.midX, y: newBounds.midY)
                self.cameraView.videoPreviewLayer.videoGravity = .resizeAspectFill
                self.cameraFinishedSetup?()
            }
            
            avSession.startRunning()
        } else {

            DispatchQueue.main.async {
                self.cameraFinishedSetup?()
            }
        }
    }
    func getCamera() -> AVCaptureDevice? {
        if let cameraDevice = AVCaptureDevice.default(.builtInDualCamera,
                                                      for: .video, position: .back) {
            return cameraDevice
        } else if let cameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                             for: .video, position: .back) {
            return cameraDevice
        } else {

            return nil
        }
    }
}
