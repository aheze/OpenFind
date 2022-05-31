//
//  PhotosSlidesItemViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import SwiftUI

class PhotosSlidesItemViewController: UIViewController {
    var model: PhotosViewModel
    var realmModel: RealmModel
    var findPhoto: FindPhoto
    var getImageBoundsSize: (() -> CGSize)?
    
    var textOverlayViewModel = PhotosTextOverlayViewModel()
    
    var highlightsViewModel = HighlightsViewModel()
    lazy var scrollZoomController = ScrollZoomViewController.make()
    lazy var highlightsViewController = HighlightsViewController(
        highlightsViewModel: highlightsViewModel,
        realmModel: realmModel
    )
    
    /// constraints are much more reliable than setting the frame of the highlights view controller
    /// these are relative to the drawing view
    var highlightsVCLeftC: NSLayoutConstraint!
    var highlightsVCTopC: NSLayoutConstraint!
    var highlightsVCWidthC: NSLayoutConstraint!
    var highlightsVCHeightC: NSLayoutConstraint!
 
    var imageFrame = CGRect.zero
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var toolbarContainer: UIView!
    @IBOutlet var toolbarContainerWidthC: NSLayoutConstraint!
    @IBOutlet var toolbarContainerHeightC: NSLayoutConstraint!
    
    init?(
        coder: NSCoder,
        model: PhotosViewModel,
        realmModel: RealmModel,
        findPhoto: FindPhoto
    ) {
        self.model = model
        self.realmModel = realmModel
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
        addChildViewController(scrollZoomController, in: contentView)
        addHighlightsViewController()
        
        toolbarContainer.isHidden = true
        reloadImage()
        
        view.backgroundColor = .clear
        containerView.backgroundColor = .clear
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
    }

    func reloadImage() {
        textOverlayViewModel.on = false
        imageFrame = getImageFrame()
        
        model.getFullImage(from: findPhoto.photo.asset) { [weak self] image in
            guard let self = self else { return }
            self.scrollZoomController.imageView.image = image
        }
        
        if
            let toolbarInformationOn = model.slidesState?.toolbarInformationOn,
            toolbarInformationOn,
            traitCollection.horizontalSizeClass != .regular
        {
            setAspectRatioToFill(percentage: 1)
        } else {
            setAspectRatioToFill(percentage: 0)
        }
    }
    
    func getImageFrame() -> CGRect {
        let asset = findPhoto.photo.asset
        let aspectRatio = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        let frame = CGRect.makeRect(aspectRatio: aspectRatio, insideRect: view.bounds)
        
        return frame
    }
    
    func setAspectRatioToFill(percentage: CGFloat) {
        let asset = findPhoto.photo.asset
        let imageSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        
        let imageBoundsSize = getImageBoundsSize?() ?? .zero
        let scaleNeeded = CGSize.scaleFor(imageSize: imageSize, scaledTo: imageBoundsSize)
        let transform = 1 + (scaleNeeded - 1) * percentage
        
        scrollZoomController.baseView.transform = CGAffineTransform(scaleX: transform, y: transform)
    }
}

extension PhotosSlidesItemViewController {
    func addToolbar() {
        let contentView = PhotosSlidesItemToolbarView(model: model, textOverlayViewModel: textOverlayViewModel) { [weak self] size in
            guard let self = self else { return }
            self.toolbarContainerWidthC.constant = size.width
            self.toolbarContainerHeightC.constant = size.height
        }
        let hostingController = UIHostingController(rootView: contentView)
        addChildViewController(hostingController, in: toolbarContainer)
        toolbarContainer.backgroundColor = .clear
        hostingController.view.backgroundColor = .clear
        
        textOverlayViewModel.$on
            .dropFirst()
            .sink { [weak self] on in
                guard let self = self else { return }
                
                if on {
//                    guard let sentences = self.findPhoto.photo.metadata?.text?.sentences else { return }
//                    let overlays: [Overlay] = sentences.map { sentence in
//                        let upperBound = sentence.components.last?.range.upperBound ?? 1
//                        let highlight = Overlay(
//                            string: sentence.string,
//                            position: sentence.position(for: 0 ..< upperBound)
//                        )
//                        return highlight
//                    }
//                    self.highlightsViewModel.overlays = overlays
                }
                withAnimation {
                    self.highlightsViewModel.showOverlays = on
                }
            }
            .store(in: &realmModel.cancellables)
    }

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
