//
//  CameraVC+Zoom.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/28/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//
    
import SwiftUI

extension CameraViewController {
    func setupZoom() {
        zoomContainerHeightC.constant = (C.zoomFactorLength + C.edgePadding * 2) + C.bottomPadding
        let zoomView = ZoomView(zoomViewModel: zoomViewModel)
        
        let hostingController = UIHostingController(rootView: zoomView)
        hostingController.view.backgroundColor = .clear
        addChild(hostingController, in: zoomContainerView)
        zoomContainerView.backgroundColor = .clear
        
        zoomCancellable = zoomViewModel.$zoom.sink { [weak self] zoom in
            self?.livePreviewViewController.changeZoom(to: zoom, animated: true)
        }
        aspectProgressCancellable = zoomViewModel.$aspectProgress.sink { [weak self] aspectProgress in
            self?.livePreviewViewController.changeAspectProgress(to: aspectProgress, animated: true)
        }
        
        cameraViewModel.shutterPressed = { [weak self] in
            guard let self = self else { return }
            self.livePreviewViewController.livePreviewView.videoPreviewLayer.connection?.isEnabled = !self.cameraViewModel.shutterOn
        }
        
        if let camera = livePreviewViewController.cameraDevice {
            zoomViewModel.configureZoomFactors(
                minZoom: camera.minAvailableVideoZoomFactor,
                maxZoom: camera.maxAvailableVideoZoomFactor,
                switchoverFactors: camera.virtualDeviceSwitchOverVideoZoomFactors
            )
        }
    }
}
