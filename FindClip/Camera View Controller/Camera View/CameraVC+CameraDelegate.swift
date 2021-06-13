//
//  CameraVC+CameraDelegate.swift
//  FindAppClip1
//
//  Created by Zheng on 3/18/21.
//

import UIKit
import AVFoundation

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // MARK:  Camera Delegate and Setup
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        if CurrentState.currentlyPaused == false {
            currentPassCount += 1
            if busyFastFinding == false {
                
                /// 1. Find
                fastFind(in: pixelBuffer)
            }
        }
    }
}

extension UIImage {
    convenience init?(pixBuffer: CVPixelBuffer) {
        var ciImage = CIImage(cvPixelBuffer: pixBuffer)
        let transform = ciImage.orientationTransform(for: CGImagePropertyOrientation(rawValue: 6)!)
        ciImage = ciImage.transformed(by: transform)
        let size = ciImage.extent.size

        let screenSize: CGRect = UIScreen.main.bounds
        let imageRect = CGRect(x: screenSize.origin.x, y: screenSize.origin.y, width: size.width, height: size.height)
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(ciImage, from: imageRect) else {
            return nil
        }
        self.init(cgImage: cgImage)
    }
}
