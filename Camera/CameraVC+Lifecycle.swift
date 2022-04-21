//
//  CameraVC+Lifecycle.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/6/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

extension CameraViewController {
    func willBecomeActive() {
        if let livePreviewViewController = livePreviewViewController, !livePreviewViewController.session.isRunning {
            DispatchQueue.global(qos: .userInteractive).async {
                self.livePreviewViewController?.session.startRunning()
            }
        }
    }
    
    func didBecomeActive() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIAccessibility.post(notification: .screenChanged, argument: self.searchContainerView)
        }
    }
    
    func willBecomeInactive() {}
    
    func didBecomeInactive() {
        Find.prioritizedAction = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + CameraConstants.cameraCoolDownDuration) {
            if self.tabViewModel.tabState != .camera {
                self.stopRunning()
            }
        }
    }
    
    func boundsChanged(to size: CGSize, safeAreaInsets: UIEdgeInsets) {}
}
