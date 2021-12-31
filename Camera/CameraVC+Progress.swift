//
//  CameraVC+Progress.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/31/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//
    

import SwiftUI

extension CameraViewController {
    func setupProgress() {
        let progressLineView = ProgressLineView(model: progressViewModel)
        let hostingController = UIHostingController(rootView: progressLineView)
        addChildViewController(hostingController, in: progressContainerView)
        hostingController.view?.backgroundColor = .clear
        progressContainerView.backgroundColor = .clear
    }
    
    func startAutoProgress(estimatedTime: CGFloat = 1.5) {
        progressViewModel.start(progress: .auto(estimatedTime: estimatedTime))
    }
    func endAutoProgress() {
        progressViewModel.finishAutoProgress()
    }
}
