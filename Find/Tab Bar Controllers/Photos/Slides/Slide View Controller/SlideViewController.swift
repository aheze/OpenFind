//
//  SlideViewController.swift
//  Find
//
//  Created by Zheng on 1/9/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import Photos

/// each slide in the slides
class SlideViewController: UIViewController {
    
    var cameFromFind = false
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    var placeholderImage: UIImage? /// placeholder from the collection view
    var resultPhoto = ResultPhoto()
    var index: Int = 0 /// index of this slide
    
    // MARK: Drawing
    @IBOutlet weak var drawingBaseView: CustomActionsView!
    @IBOutlet weak var drawingView: UIView!
    var highlights = [Component]()
    var matchToColors = [String: [HighlightColor]]()
    
    // MARK: Accessibility
    var showingTranscripts = false
    var currentTranscriptComponents = [Component]()
    var previousActivatedHighlight: Component?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        scrollView.contentInsetAdjustmentBehavior = .never
        
        imageView.image = placeholderImage
        
        let scale = UIScreen.main.scale
        let targetSize = CGSize(width: contentView.bounds.width * scale, height: contentView.bounds.height * scale)
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        manager.requestImage(for: resultPhoto.findPhoto.asset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { (result, info) in
            if let photo = result {
                self.imageView.image = photo
            }
        })
        
        if cameFromFind {
            view.layoutIfNeeded()
            DispatchQueue.main.async {
                self.drawHighlights()
            }
        }
        
        setupAccessibility()
        
        drawAllTranscripts(show: showingTranscripts)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
        updateHighlightFrames()
    }
}

