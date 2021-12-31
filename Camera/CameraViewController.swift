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
   
    
    // MARK: - Sub view controllers

    lazy var livePreviewViewController = createLivePreview()
    lazy var searchViewController = createSearchBar()
    
    @IBOutlet var searchContainerView: UIView!
    
    @IBOutlet var zoomContainerView: UIView!
    @IBOutlet var zoomContainerHeightC: NSLayoutConstraint!
    
    @IBOutlet var livePreviewContainerView: UIView!
    @IBOutlet var safeView: UIView!
    
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
    }
    
    func setup() {
        _ = livePreviewViewController
        _ = searchViewController
        
        view.backgroundColor = Constants.darkBlueBackground
        safeView.backgroundColor = .clear
        
        setupZoom()
    }
}

extension CameraViewController {
    func willBecomeActive() {}
    
    func didBecomeActive() {}
    
    func willBecomeInactive() {}
    
    func didBecomeInactive() {}
}
