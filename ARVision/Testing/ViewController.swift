//
//  ViewController.swift
//  AR
//
//  Created by Zheng on 11/24/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import AVFoundation
import UIKit
import Vision

class ViewController: UIViewController {
    /// original, unscaled image size (pretty large)
    var imageSize: CGSize?
    
    /// image scaled down to the view
    var imageFitViewRect = CGRect.zero
    
    let session = AVCaptureSession()
    let videoDataOutput = AVCaptureVideoDataOutput()
    var cameraDevice: AVCaptureDevice?
    var captureCompletionBlock: ((UIImage) -> Void)?
    
    var latestPixelBuffer: CVPixelBuffer?
    let visionEngine = VisionEngine()
    
    @IBOutlet var livePreviewView: LivePreviewView!
    @IBOutlet var imageFitView: UIView!
    @IBOutlet var averageView: UIView!
    
    @IBAction func resetPressed(_ sender: Any) {
        if let latestPixelBuffer = latestPixelBuffer {
            if visionEngine.canFind {
                visionEngine.startToFind(["Hi"], in: latestPixelBuffer)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        averageView.addDebugBorders(.systemCyan)
        configureCamera()
        visionEngine.delegate = self
    }
    
    var count = 0
}

extension ViewController: VisionEngineDelegate {
    func textFound(observations: [VNRecognizedTextObservation]) {
        for subview in imageFitView.subviews {
            if subview.layer.borderWidth == 1.5 {
                subview.removeFromSuperview()
            }
        }
        
        for observation in observations {
            var adjustedBoundingBox = observation.boundingBox
            
            /// adjust for vision coordinates
            adjustedBoundingBox.origin.y = 1 - observation.boundingBox.minY - observation.boundingBox.height
            
            let adjustedBoundingBoxScaled = adjustedBoundingBox.scaleTo(imageFitViewRect)
            let newView = UIView(frame: adjustedBoundingBoxScaled)
            
            newView.addDebugBorders(UIColor.yellow, width: 1.5)
            imageFitView.addSubview(newView)
        }
    }
    
    func cameraMoved(by translation: CGSize) {
        updateTranslation(with: translation)
    }
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        latestPixelBuffer = pixelBuffer
        let size = CVImageBufferGetDisplaySize(pixelBuffer)
        if imageSize == nil {
            imageSize = CGSize(width: size.width, height: size.height)
            updateViewportSize()
        }
        
        if visionEngine.canFind {
            visionEngine.startToFind(["Hi"], in: pixelBuffer)
        }
        visionEngine.updatePixelBuffer(pixelBuffer)
    }
    
    func updateTranslation(with translation: CGSize) {
        UIView.animate(withDuration: 0.3) {
            let originalCenter = CGPoint(x: self.imageFitViewRect.width / 2, y: self.imageFitViewRect.height / 2)
            self.averageView.center.x = originalCenter.x + (translation.width * self.imageFitViewRect.width)
            self.averageView.center.y = originalCenter.y - (translation.height * self.imageFitViewRect.height)
        }
    }
}

extension CGRect {
    func scaleTo(_ newRect: CGRect) -> CGRect {
        let scaledRect = CGRect(
            x: origin.x * newRect.width,
            y: origin.y * newRect.height,
            width: width * newRect.width,
            height: height * newRect.height
        )
        return scaledRect
    }
}
