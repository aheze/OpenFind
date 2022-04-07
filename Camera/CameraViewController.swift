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
    
    lazy var zoomViewModel = ZoomViewModel(containerView: zoomContainerView)
    var aspectProgressCancellable: AnyCancellable?
    
    var searchViewModel = SearchViewModel(configuration: .camera)
    var highlightsViewModel = HighlightsViewModel()
    var messagesViewModel = CameraMessagesViewModel()
    
    // MARK: - Sub view controllers

    lazy var livePreviewViewController = createLivePreview()
    lazy var searchViewController = createSearchBar()
    lazy var scrollZoomViewController = createScrollZoom()
    lazy var scrollZoomHookViewController = createScrollZoomHook()
    
    @IBOutlet var searchContainerView: UIView!
    
    var progressViewModel = ProgressViewModel()
    @IBOutlet var progressContainerView: UIView!
    
    /// should match the frame of the image
    @IBOutlet var contentContainerView: UIView!

    /// saved for background thread access
    var contentContainerViewSize = CGSize.zero
    
    /// Inside the drawing view
    @IBOutlet var scrollZoomContainerView: UIView!
    @IBOutlet var scrollZoomHookContainerView: UIView!
    
    /// inside the drawing view, should match the safe view
    @IBOutlet var simulatedSafeView: UIView!
    
    @IBOutlet var livePreviewContainerView: UIView!
    
    @IBOutlet var zoomContainerView: UIView!
    @IBOutlet var zoomContainerHeightC: NSLayoutConstraint!
    
    @IBOutlet var safeView: UIView!
    
    var blurOverlayView = CameraBlurOverlayView()
    
    /// Testing tab bar view
    @IBOutlet var testingTabBarContainerView: UIView!
    
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

        setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        livePreviewViewController.updateViewportSize(safeViewFrame: safeView.frame)
        livePreviewViewController.changeAspectProgress(to: zoomViewModel.aspectProgress, animated: false)
        contentContainerViewSize = contentContainerView.bounds.size
    }
    
    func setup() {
        _ = livePreviewViewController
        _ = searchViewController
        
        view.backgroundColor = Constants.darkBlueBackground
        safeView.backgroundColor = .clear
        contentContainerView.backgroundColor = .clear
        scrollZoomContainerView.backgroundColor = .clear
        scrollZoomHookContainerView.backgroundColor = .clear
        simulatedSafeView.backgroundColor = .clear
        simulatedSafeView.isHidden = true
        
        setupZoom()
        setupHighlights()
        setupProgress()
        setupBlur()
        
        listenToModel()
        
        /// A testing tab bar
        addTestingTabBar(add: false)
    }
}

