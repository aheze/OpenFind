//
//  ScrollZoomViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/31/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//

import UIKit

class ScrollZoomViewController: UIViewController {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var baseView: UIView! /// inside `contentView`
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var drawingView: UIView!

    /// normal zoom scale, nothing to do with camera zoom
    static var minimumZoomScale = CGFloat(1)
    static var maximumZoomScale = CGFloat(3.5)

    static func make() -> ScrollZoomViewController {
        let storyboard = UIStoryboard(name: "ScrollZoomContent", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ScrollZoomViewController") as! ScrollZoomViewController
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        baseView.backgroundColor = .clear
        contentView.backgroundColor = .clear
        imageView.backgroundColor = .clear
        imageView.clipsToBounds = true
        drawingView.backgroundColor = .clear

        scrollView.delegate = self
        scrollView.minimumZoomScale = ScrollZoomViewController.minimumZoomScale
        scrollView.maximumZoomScale = ScrollZoomViewController.maximumZoomScale
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false

        scrollView.contentInsetAdjustmentBehavior = .never
    }

    func centerImage() {
        if scrollView.zoomScale < 1 {
            let leftMargin = (scrollView.bounds.width - contentView.frame.width) * 0.5
            let topMargin = (scrollView.bounds.height - contentView.frame.height) * 0.5
            scrollView.contentInset = UIEdgeInsets(top: topMargin, left: leftMargin, bottom: 0, right: 0)
        } else {
            scrollView.contentInset = .zero
        }
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
