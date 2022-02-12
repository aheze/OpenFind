//
//  CameraVC+LivePreview.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/28/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//
    
import UIKit

extension CameraViewController {
    func createLivePreview() -> LivePreviewViewController {
        let storyboard = UIStoryboard(name: "CameraContent", bundle: nil)
        let livePreviewViewController = storyboard.instantiateViewController(withIdentifier: "LivePreviewViewController") as! LivePreviewViewController
        
        livePreviewViewController.findFromPhotosButtonPressed = {
            Tab.Control.moveToOtherTab?(.photos, true)
        }
        
        /// called when an image is first returned
        livePreviewViewController.needSafeViewUpdate = { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                livePreviewViewController.updateViewportSize(safeViewFrame: self.safeView.frame)
                livePreviewViewController.changeZoom(to: self.zoomViewModel.zoom, animated: false)
                livePreviewViewController.changeAspectProgress(to: self.zoomViewModel.aspectProgress, animated: false)
            }
        }
        
        livePreviewViewController.changeContentContainerViewFrame = { [weak self] frame in
            guard let self = self else { return }
            self.contentContainerView.frame = frame
            self.contentContainerView.alpha = 1
        }
        
        livePreviewViewController.changeSimulatedSafeViewFrame = { [weak self] frame in
            guard let self = self else { return }
            self.simulatedSafeView.frame = frame
            self.simulatedSafeView.alpha = 1
        }
        
        livePreviewViewController.frameCaptured = { [weak self] pixelBuffer in
            guard let self = self else { return }
            
            if !self.model.shutterOn {
                self.findAndAddHighlights(pixelBuffer: pixelBuffer)
            }
        }
        
        addChildViewController(livePreviewViewController, in: livePreviewContainerView)
        
        livePreviewContainerView.backgroundColor = .clear
        livePreviewViewController.view.backgroundColor = .clear
        return livePreviewViewController
    }
    func showLivePreview() {
        self.livePreviewContainerView.alpha = 1
    }
    func hideLivePreview() {
        UIView.animate(withDuration: 0.8) {
            self.livePreviewContainerView.alpha = 0
        }
    }
}
