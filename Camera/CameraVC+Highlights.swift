//
//  CameraVC+Highlights.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/30/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//
    

import UIKit

extension CameraViewController {
    func setupHighlights() {
        /// for highlights, make appear after frames are set

        let highlightsViewController = HighlightsViewController(highlightsViewModel: highlightsViewModel)
        addChildViewController(highlightsViewController, in: scrollZoomViewController.drawingView)
    }
}
