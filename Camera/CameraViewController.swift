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
    var realmModel: RealmModel
    
    lazy var zoomViewModel = ZoomViewModel(containerView: zoomContainerView)
    var aspectProgressCancellable: AnyCancellable?
    
    var searchViewModel = SearchViewModel(configuration: .camera)
    var highlightsViewModel = HighlightsViewModel()
    
    // MARK: - Sub view controllers

    lazy var livePreviewViewController = createLivePreview()
    lazy var searchViewController = createSearchBar()
    lazy var scrollZoomViewController = createScrollZoom()
    lazy var scrollZoomHookViewController = createScrollZoomHook()
    
    @IBOutlet var searchContainerView: UIView!
    
    var progressViewModel = ProgressViewModel()
    @IBOutlet weak var progressContainerView: UIView!
    
    
    /// should match the frame of the image
    @IBOutlet var contentContainerView: UIView!

    /// saved for background thread access
    var contentContainerViewSize = CGSize.zero
    
    /// Inside the drawing view
    @IBOutlet weak var scrollZoomContainerView: UIView!
    @IBOutlet weak var scrollZoomHookContainerView: UIView!
    
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
        realmModel: RealmModel
    ) {
        self.cameraViewModel = cameraViewModel
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
    
    func boundsChanged(to size: CGSize, safeAreaInset: UIEdgeInsets) {
        
    }
}
