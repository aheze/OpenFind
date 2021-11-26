//
//  ViewController.swift
//  AR
//
//  Created by Zheng on 11/24/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    /// original, unscaled image size (pretty large)
    var imageSize: CGSize?
    
    /// image scaled down to the view
    var imageFitViewRect = CGRect.zero
    
    let session = AVCaptureSession()
    let videoDataOutput = AVCaptureVideoDataOutput()
    var cameraDevice: AVCaptureDevice?
    var captureCompletionBlock: ((UIImage) -> Void)?
    
    @IBOutlet weak var livePreviewView: LivePreviewView!
    @IBOutlet weak var imageFitView: UIView!
    @IBOutlet weak var averageView: UIView!
    
    
    @IBAction func resetPressed(_ sender: Any) {
        if let latestPixelBuffer = latestPixelBuffer {
            engine.beginTracking(with: latestPixelBuffer, boundingBox: CGRect(x: 0.3, y: 0.3, width: 0.4, height: 0.4))
        }
        resetAverageView()
    }
    
    var latestPixelBuffer: CVPixelBuffer?
    let engine = VisionEngine()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageFitView.backgroundColor = .clear
        averageView.addDebugBorders(.systemCyan)
        configureCamera()
    }
    
    var count = 0
}


extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        self.latestPixelBuffer = pixelBuffer
        let size = CVImageBufferGetDisplaySize(pixelBuffer)
        if imageSize == nil {
            imageSize = CGSize(width: size.width, height: size.height)
            updateViewportSize()
        }
        if engine.previousObservation == nil {
            engine.beginTracking(with: pixelBuffer, boundingBox: CGRect(x: 0.3, y: 0.3, width: 0.4, height: 0.4))
        }
        
        engine.updateTracking(with: pixelBuffer) { rect in
            DispatchQueue.main.async {
                self.updateFrame(with: rect)
            }
        }
    }
    
    func updateFrame(with rect: CGRect) {
        UIView.animate(withDuration: 0.3) {
            var transformedRect = rect
            transformedRect.origin.y = 1.0 - rect.origin.y - rect.size.height
            let scaledRect = transformedRect.scaleTo(self.imageFitViewRect)
            self.averageView.frame = scaledRect
        }
    }
}

extension CGRect {
    func scaleTo(_ newRect: CGRect) -> CGRect {
        let scaledRect = CGRect(
            x: self.origin.x * newRect.width,
            y: self.origin.y * newRect.height,
            width: self.width * newRect.width,
            height: self.height * newRect.height
        )
        return scaledRect
    }
}
