//
//  ScrollZoomViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/31/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//


import UIKit

class ScrollZoomViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var drawingView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        contentView.backgroundColor = .clear
        imageView.backgroundColor = .clear
        imageView.clipsToBounds = true
        drawingView.backgroundColor = .clear
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 2.5
        
    }
}

extension ScrollZoomViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }
    
    /// center the image
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let leftMargin = (scrollView.bounds.width - contentView.frame.width) * 0.5
        let topMargin = (scrollView.bounds.height - contentView.frame.height) * 0.5
        scrollView.contentOffset = CGPoint(x: -leftMargin, y: -topMargin)
    }
}


