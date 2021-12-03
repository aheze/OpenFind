//
//  CameraVC+LivePreview.swift
//  Camera
//
//  Created by Zheng on 12/1/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
extension CameraViewController {
    func createLivePreviewViewController() -> LivePreviewViewController {
        let storyboard = UIStoryboard(name: "CameraContent", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "LivePreviewViewController") as! LivePreviewViewController
        
        viewController.findFromPhotosButtonPressed = { [weak self] in
            TabControl.moveToOtherTab?(.photos, true)
        }
        viewController.needSafeViewUpdate = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                viewController.updateViewportSize(safeViewFrame: self.safeView.frame)
                viewController.changeZoom(to: self.zoomViewModel.zoom, animated: false)
                viewController.changeAspectProgress(to: self.zoomViewModel.aspectProgress, animated: false)
            }
        }
        
        self.addChild(viewController, in: livePreviewContainerView)
        
        livePreviewContainerView.backgroundColor = .clear
        viewController.view.backgroundColor = .clear
        return viewController
    }
}
