//
//  LivePreviewVC+Setup.swift
//  Camera
//
//  Created by Zheng on 11/21/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import AVFoundation
import SwiftUI

extension LivePreviewViewController {
    func configureCamera() {
        if let cameraDevice = getCamera() {
            self.cameraDevice = cameraDevice
            
            DispatchQueue.global(qos: .userInteractive).async {
                self.configureSession()
            }
        } else {
            let cameraNotFoundView = CameraNotFoundView()
            let hostingController = UIHostingController(rootView: cameraNotFoundView)
            addChildViewController(hostingController, in: view)
            view.bringSubviewToFront(hostingController.view)
            hostingController.view?.backgroundColor = .white

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
        
        if session.canAddOutput(photoDataOutput) {
            session.addOutput(photoDataOutput)
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
