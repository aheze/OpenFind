//
//  SlideViewController.swift
//  Find
//
//  Created by Zheng on 1/9/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import Photos
import UIKit

/// each slide in the slides
class SlideViewController: UIViewController {
    var cameFromFind = false
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var imageView: UIImageView!
    
    var placeholderImage: UIImage? /// placeholder from the collection view
    var resultPhoto = ResultPhoto()
    var index: Int = 0 /// index of this slide
    
    // MARK: Drawing

    var findingActive = false
    @IBOutlet var drawingBaseView: CustomActionsView!
    @IBOutlet var drawingView: UIView!
    var matchToColors = [String: [HighlightColor]]()
    
    // MARK: Accessibility

    var showingTranscripts = false
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
        manager.requestImage(for: resultPhoto.findPhoto.asset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { result, _ in
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
