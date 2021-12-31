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
    
    /// external models
    var cameraViewModel: CameraViewModel
    var listsViewModel: ListsViewModel
    
    lazy var zoomViewModel = ZoomViewModel(containerView: zoomContainerView)
    var zoomCancellable: AnyCancellable?
    var aspectProgressCancellable: AnyCancellable?
    
    var searchViewModel = SearchViewModel()
    var highlightsViewModel = HighlightsViewModel()
    
    // MARK: - Sub view controllers

    lazy var livePreviewViewController = createLivePreview()
    lazy var searchViewController = createSearchBar()
    
    @IBOutlet var searchContainerView: UIView!
    
    var progressViewModel = ProgressViewModel()
    @IBOutlet weak var progressContainerView: UIView!
    
    
    /// should match the frame of the image
    @IBOutlet var drawingView: UIView!
    var drawingViewSize = CGSize.zero
    
    /// inside the drawing view, should match the safe view
    @IBOutlet var simulatedSafeView: UIView!
    
    @IBOutlet var livePreviewContainerView: UIView!
    
    @IBOutlet var zoomContainerView: UIView!
    @IBOutlet var zoomContainerHeightC: NSLayoutConstraint!
    
    @IBOutlet var safeView: UIView!
    
    /// Testing tab bar view
    @IBOutlet weak var testingTabBarContainerView: UIView!
    
    init?(
        coder: NSCoder,
        cameraViewModel: CameraViewModel,
        listsViewModel: ListsViewModel
    ) {
        self.cameraViewModel = cameraViewModel
        self.listsViewModel = listsViewModel
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
        drawingViewSize = drawingView.bounds.size
    }
    
    func setup() {
        _ = livePreviewViewController
        _ = searchViewController
        
        view.backgroundColor = Constants.darkBlueBackground
        safeView.backgroundColor = .clear
        
        setupZoom()
        setupHighlights()
        setupProgress()
        setupStatic()
        
        /// A testing tab bar
        addTestingTabBar(add: false)
    }
}

extension CameraViewController {
    func willBecomeActive() {}
    
    func didBecomeActive() {}
    
    func willBecomeInactive() {}
    
    func didBecomeInactive() {}
}
