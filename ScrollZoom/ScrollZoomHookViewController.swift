//
//  ScrollZoomHookViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/7/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

class ScrollZoomHookViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    
    /// called when the scroll view zoomed, for zooming when live preview is live
    var zoomed: ((CGFloat) -> Void)?
    var stoppedZooming: (() -> Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        contentView.backgroundColor = .clear
        scrollView.delegate = self
    }
}

extension ScrollZoomHookViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if (scrollView.isTracking || scrollView.isDragging || scrollView.isDecelerating) {
            zoomed?(scrollView.zoomScale)
        }
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        stoppedZooming?()
    }
}
