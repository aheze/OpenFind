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
        print("Start running. (active)")
        if let livePreviewViewController = livePreviewViewController, !livePreviewViewController.session.isRunning {
            DispatchQueue.global(qos: .userInteractive).async {
                print("->> Start running.")
                self.livePreviewViewController?.session.startRunning()
            }
        }
    }
    
    func didBecomeActive() {}
    
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
