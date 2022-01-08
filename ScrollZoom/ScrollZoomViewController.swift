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
    
    /// normal zoom scale, nothing to do with camera zoom
    static var minimumZoomScale = CGFloat(1)
    static var maximumZoomScale = CGFloat(2.5)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        contentView.backgroundColor = .clear
        imageView.backgroundColor = .clear
        imageView.clipsToBounds = true
        drawingView.backgroundColor = .clear
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = ScrollZoomViewController.minimumZoomScale
        scrollView.maximumZoomScale = ScrollZoomViewController.maximumZoomScale
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
    }
    
    func centerImage() {
        let leftMargin = (scrollView.bounds.width - contentView.frame.width) * 0.5
        let topMargin = (scrollView.bounds.height - contentView.frame.height) * 0.5
        scrollView.contentInset = UIEdgeInsets(top: topMargin, left: leftMargin, bottom: 0, right: 0)
    }
}

extension ScrollZoomViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }
    
    /// center the image
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        centerImage()
    }
}




