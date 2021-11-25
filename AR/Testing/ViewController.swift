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
    
    @IBOutlet weak var debugView0: UIView!
    @IBOutlet weak var debugView1: UIView!
    @IBOutlet weak var debugView2: UIView!
    @IBOutlet weak var debugView3: UIView!
    @IBOutlet weak var debugView4: UIView!
    @IBOutlet weak var debugView5: UIView!
    @IBOutlet weak var debugView6: UIView!
    @IBOutlet weak var debugView7: UIView!
    @IBOutlet weak var debugView8: UIView!
    var debugViews: [UIView] {
        return [
            debugView0,
            debugView1,
            debugView2,
            debugView3,
            debugView4,
            debugView5,
            debugView6,
            debugView7,
            debugView8
        ]
    }
    
    
    
    
    @IBAction func resetPressed(_ sender: Any) {
        print("reset!")
        for index in frames.indices {
            self.debugViews[index].frame = frames[index]
        }
        
        if let currentImage = engine.currentImage {
            print("yes")
            //            engine.beginTracking(with: currentImage)
            engine.currentImage = nil
        }
    }
    
    let engine = VisionEngine()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageFitView.addDebugBorders(.blue)
        
        for debugView in debugViews {
            debugView.addDebugBorders(.green)
        }
        
        resetFrames()
        for index in frames.indices {
            self.debugViews[index].frame = frames[index]
        }
        
        
        configureCamera()
    }
    
    
    var frames = [CGRect]()
    func resetFrames() {
        var frames = [CGRect]()
        for index in debugViews.indices {
            let area = Area.areas[index]
            let scaledRect = CGRect(
                x: area.rect.origin.x * CGFloat(imageFitView.frame.width),
                y: area.rect.origin.y * CGFloat(imageFitView.frame.height),
                width: area.rect.width * CGFloat(imageFitView.frame.width),
                height: area.rect.width * CGFloat(imageFitView.frame.height)
            )
            frames.append(scaledRect)
        }
        self.frames = frames
    }
}


extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let size = CVImageBufferGetDisplaySize(pixelBuffer)
        if imageSize == nil {
            imageSize = CGSize(width: size.height, height: size.width)
            updateViewportSize()
        }
        if engine.currentImage == nil {
            engine.beginTracking(with: pixelBuffer)
        }
        
        engine.updateTracking(with: pixelBuffer) { areas in
            
            DispatchQueue.main.async {
                for index in areas.indices {
                    var frame = self.frames[index]
                    let area = areas[index]
                    
                    frame.origin.x += area.translation.height
                    frame.origin.y += area.translation.width
                    UIView.animate(withDuration: 0.5) {
                        self.debugViews[index].frame = frame
                    }
                }
            }
        }
    }
}
