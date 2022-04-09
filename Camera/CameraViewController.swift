//
//  CameraViewController.swift
//  Camera
//
//  Created by Zheng on 11/18/21.
//

import Combine
import SwiftUI

class CameraViewController: UIViewController, PageViewController {
    var tabType: TabState = .camera
    
    var model: CameraViewModel
    
    /// external models
    var tabViewModel: TabViewModel
    var realmModel: RealmModel
    
    lazy var permissionsViewModel = CameraPermissionsViewModel()
    lazy var zoomViewModel = ZoomViewModel(containerView: zoomContainerView)
    var aspectProgressCancellable: AnyCancellable?
    
    var searchViewModel = SearchViewModel(configuration: .camera)
    var highlightsViewModel = HighlightsViewModel()
    var messagesViewModel = CameraMessagesViewModel()
    
    // MARK: - Sub view controllers

    var livePreviewViewController: LivePreviewViewController?
    lazy var searchViewController = createSearchBar()
    lazy var scrollZoomViewController = createScrollZoom()
    lazy var scrollZoomHookViewController = createScrollZoomHook()
    
    // MARK: Search bar

    @IBOutlet var searchContainerView: UIView!
    
    var progressViewModel = ProgressViewModel()
    @IBOutlet var progressContainerView: UIView!
    
    // MARK: Camera content

    /// should match the frame of the image, includes highlights
    @IBOutlet var contentContainerView: UIView!

    /// saved for background thread access
    var contentContainerViewSize = CGSize.zero
    
    /// Inside the drawing view
    @IBOutlet var scrollZoomContainerView: UIView!
    @IBOutlet var scrollZoomHookContainerView: UIView!
    
    /// inside the drawing view, should match the safe view
    @IBOutlet var simulatedSafeView: UIView!
    @IBOutlet var safeView: UIView!
    @IBOutlet var livePreviewContainerView: UIView!
    
    var blurOverlayView = CameraBlurOverlayView()
    
    // MARK: Zoom

    @IBOutlet var zoomContainerView: UIView!
    @IBOutlet var zoomContainerHeightC: NSLayoutConstraint!
    
    // MARK: Landscape

    @IBOutlet var landscapeToolbarContainer: UIView!
    @IBOutlet var landscapeToolbarWidthC: NSLayoutConstraint!
    
    init?(
        coder: NSCoder,
        model: CameraViewModel,
        tabViewModel: TabViewModel,
        realmModel: RealmModel
    ) {
        self.model = model
        self.tabViewModel = tabViewModel
        self.realmModel = realmModel
        super.init(coder: coder)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("You must create this view controller with metadata.")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = searchViewController
        setup()
        listenToModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let livePreviewViewController = livePreviewViewController else { return }
        Task {
            await livePreviewViewController.updateViewportSize(safeViewFrame: safeView.frame)
            livePreviewViewController.changeAspectProgress(to: zoomViewModel.aspectProgress, animated: false)
            contentContainerViewSize = contentContainerView.bounds.size
        }
    }
    

    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        updateLandscapeToolbar()
    }
}
