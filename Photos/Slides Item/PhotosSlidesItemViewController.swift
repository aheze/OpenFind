//
//  PhotosSlidesItemViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

class PhotosSlidesItemViewController: UIViewController {
    var highlightsViewModel = HighlightsViewModel()
    lazy var scrollZoomController = ScrollZoomViewController.make()
    lazy var highlightsViewController = HighlightsViewController(highlightsViewModel: highlightsViewModel)
 
    var model: PhotosViewModel
    var findPhoto: FindPhoto
    var imageFrame = CGRect.zero
    
    @IBOutlet var containerView: UIView!
    
    init?(coder: NSCoder, model: PhotosViewModel, findPhoto: FindPhoto) {
        self.model = model
        self.findPhoto = findPhoto
        super.init(coder: coder)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("You must create this view controller with metadata.")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = scrollZoomController
        addChildViewController(scrollZoomController, in: containerView)
        scrollZoomController.addChildViewController(highlightsViewController, in: scrollZoomController.drawingView)
        reloadImage()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageFrame = getImageFrame()
        highlightsViewController.view.frame = imageFrame
    }

    func reloadImage() {
        if let image = findPhoto.fullImage {
            scrollZoomController.imageView.image = image
        } else {
            model.getFullImage(from: findPhoto.photo) { [weak self] image in
                guard let self = self else { return }
                self.findPhoto.fullImage = image
                self.scrollZoomController.imageView.image = image
            }
        }
    }
    
    func getImageFrame() -> CGRect {
        let asset = findPhoto.photo.asset
        let aspectRatio = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        let frame = CGRect.makeRect(aspectRatio: aspectRatio, insideRect: view.bounds)
        
        return frame
    }
}
