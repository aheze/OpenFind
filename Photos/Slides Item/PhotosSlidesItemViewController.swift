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
    
    /// constraints are much more reliable than setting the frame of the highlights view controller
    /// these are relative to the drawing view
    var highlightsVCLeftC: NSLayoutConstraint!
    var highlightsVCTopC: NSLayoutConstraint!
    var highlightsVCWidthC: NSLayoutConstraint!
    var highlightsVCHeightC: NSLayoutConstraint!
 
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
        _ = highlightsViewController
        addChildViewController(scrollZoomController, in: containerView)
        addHighlightsViewController()
        reloadImage()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageFrame = getImageFrame()
        imageFrame.setAsConstraints(
            left: highlightsVCLeftC,
            top: highlightsVCTopC,
            width: highlightsVCWidthC,
            height: highlightsVCHeightC
        )
        
        if model.slidesState?.toolbarInformationOn ?? false {
            setAspectRatio(scaleToFill: true)
        } else {
            setAspectRatio(scaleToFill: false)
        }
    }

    func reloadImage() {
        imageFrame = getImageFrame()
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
    
    func setAspectRatio(scaleToFill: Bool) {
        let asset = findPhoto.photo.asset
        let imageSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        if scaleToFill {
            let scale = CGSize.scaleFor(imageSize: imageSize, scaledTo: view.bounds.size)
            
            scrollZoomController.baseView.transform = CGAffineTransform(scaleX: scale, y: scale)
        } else {
            scrollZoomController.baseView.transform = .identity
        }
    }
}

extension PhotosSlidesItemViewController {
    func addHighlightsViewController() {
        /// Add Child View Controller
        scrollZoomController.addChild(highlightsViewController)
        
        guard
            let containerView = scrollZoomController.drawingView,
            let highlightsView = highlightsViewController.view
        else { return }

        containerView.insertSubview(highlightsView, at: 0)

        /// Configure Child View
        highlightsView.translatesAutoresizingMaskIntoConstraints = false
        highlightsVCLeftC = highlightsView.leftAnchor.constraint(equalTo: containerView.leftAnchor)
        highlightsVCTopC = highlightsView.topAnchor.constraint(equalTo: containerView.topAnchor)
        highlightsVCWidthC = highlightsView.widthAnchor.constraint(equalToConstant: containerView.bounds.width)
        highlightsVCHeightC = highlightsView.heightAnchor.constraint(equalToConstant: containerView.bounds.height)
        
        NSLayoutConstraint.activate([
            highlightsVCLeftC,
            highlightsVCTopC,
            highlightsVCWidthC,
            highlightsVCHeightC
        ])
    
        /// Notify Child View Controller
        highlightsViewController.didMove(toParent: scrollZoomController)
    }
}
