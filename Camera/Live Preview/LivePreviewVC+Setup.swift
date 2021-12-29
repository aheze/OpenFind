//
//  LivePreviewVC+Setup.swift
//  Camera
//
//  Created by Zheng on 11/21/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import AVFoundation
import SnapKit
import UIKit

extension LivePreviewViewController {
    func configureCamera() {
        if let cameraDevice = getCamera() {
            self.cameraDevice = cameraDevice
            
            DispatchQueue.global(qos: .userInteractive).async {
                self.configureSession()
            }
        } else {
            let fallbackView = FallbackView()
            view.addSubview(fallbackView)
            fallbackView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            fallbackView.goToPhotos = { [weak self] in
                self?.findFromPhotosButtonPressed?()
            }
        }
    }
    
    func configureSession() {
        guard let cameraDevice = cameraDevice else { return }
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: cameraDevice)
            if session.canAddInput(captureDeviceInput) {
                session.addInput(captureDeviceInput)
            }
        } catch {
            return
        }
        session.sessionPreset = .photo
        videoDataOutput.setSampleBufferDelegate(
            self,
            queue: DispatchQueue(
                label: "Buffer Queue",
                qos: .userInteractive,
                attributes: .concurrent,
                autoreleaseFrequency: .inherit,
                target: nil
            )
        )
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
        }
        
        DispatchQueue.main.async {
            self.addSession()
        }
        
        session.startRunning()
    }
    
    func addSession() {
        let viewBounds = view.layer.bounds
        
        livePreviewView.session = session
        livePreviewView.videoPreviewLayer.bounds = viewBounds
        livePreviewView.videoPreviewLayer.position = CGPoint(x: viewBounds.midX, y: viewBounds.midY)
        livePreviewView.videoPreviewLayer.videoGravity = .resizeAspect
    }
    
    func getCamera() -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [
                .builtInTripleCamera,
                .builtInDualWideCamera,
                .builtInDualCamera,
                .builtInWideAngleCamera
            ],
            mediaType: .video,
            position: .back
        )
        let devices = discoverySession.devices
        let bestDevice = devices.first

        return bestDevice
    }
}
