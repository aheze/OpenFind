//
//  CameraViewController.swift
//  Camera
//
//  Created by Zheng on 11/18/21.
//

import SwiftUI
import Combine

class CameraViewController: UIViewController, PageViewController {
    
    var tabType: TabState = .camera
    
    var cameraViewModel: CameraViewModel
    lazy var zoomViewModel = ZoomViewModel(containerView: zoomContainerView)
    var zoomCancellable: AnyCancellable?
    var aspectProgressCancellable: AnyCancellable?
    
    var searchViewModel = SearchViewModel()
    var listsViewModel = ListsViewModel()
    
    // MARK: - Sub view controllers
    lazy var livePreviewViewController = createLivePreview()
    lazy var searchViewController = createSearchBar()
    
    @IBOutlet weak var searchContainerView: UIView!
    
    @IBOutlet weak var zoomContainerView: UIView!
    @IBOutlet weak var zoomContainerHeightC: NSLayoutConstraint!
    
    @IBOutlet weak var livePreviewContainerView: UIView!
    @IBOutlet weak var safeView: UIView!
    
    
    init?(
        coder: NSCoder,
        cameraViewModel: CameraViewModel
    ) {
        self.cameraViewModel = cameraViewModel
        super.init(coder: coder)
    }
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
        
        
        searchContainerView.addDebugBorders(.blue)
        searchContainerView.isUserInteractionEnabled = true
    }
}

extension CameraViewController {
    func willBecomeActive() {
        
    }
    
    func didBecomeActive() {
        
    }
    
    func willBecomeInactive() {
        
    }
    
    func didBecomeInactive() {
        
    }
    
}



