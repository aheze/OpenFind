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
    var zoomViewModel: ZoomViewModel!
    
    private var zoomCancellable: AnyCancellable?
    private var aspectProgressCancellable: AnyCancellable?
    
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var searchContainerHeightC: NSLayoutConstraint!
    
    @IBOutlet weak var zoomContainerView: UIView!
    @IBOutlet weak var zoomContainerHeightC: NSLayoutConstraint!
    
    @IBOutlet weak var livePreviewContainerView: UIView!
    lazy var livePreviewViewController: LivePreviewViewController = {
        return createLivePreviewViewController()
    }()
    
    @IBOutlet weak var safeView: UIView!
    
    lazy var toolbar: CameraToolbarView = {
        return CameraToolbarView(viewModel: cameraViewModel)
    }()
    
    init?(coder: NSCoder, cameraViewModel: CameraViewModel) {
        self.cameraViewModel = cameraViewModel
        super.init(coder: coder)
    }
    required init?(coder: NSCoder) {
        fatalError("You must create this view controller with metadata.")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Camera loaded")
        print("View bounds: \(view.bounds)")
        setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        livePreviewViewController.updateViewportSize(safeViewFrame: safeView.frame)
        livePreviewViewController.changeAspectProgress(to: zoomViewModel.aspectProgress)
    }
    
    func setup() {
        view.backgroundColor = Constants.darkBlueBackground
        safeView.backgroundColor = .clear
        
        zoomContainerHeightC.constant = (C.zoomFactorLength + C.edgePadding * 2) + C.bottomPadding
        self.zoomViewModel = .init(containerView: zoomContainerView)
        let zoomView = ZoomView(zoomViewModel: self.zoomViewModel)
        let hostingController = UIHostingController(rootView: zoomView)
        hostingController.view.backgroundColor = .clear
        addChild(hostingController, in: zoomContainerView)
        zoomContainerView.backgroundColor = .clear
        
        zoomCancellable = zoomViewModel.$zoom.sink { [weak self] zoom in
            self?.livePreviewViewController.changeZoom(to: zoom, animated: true)
        }
        aspectProgressCancellable = zoomViewModel.$aspectProgress.sink { [weak self] aspectProgress in
            self?.livePreviewViewController.changeAspectProgress(to: aspectProgress)
        }
        
        
        
        _ = livePreviewViewController
        
        if let camera = livePreviewViewController.cameraDevice {
            zoomViewModel.configureZoomFactors(
                minZoom: camera.minAvailableVideoZoomFactor,
                maxZoom: camera.maxAvailableVideoZoomFactor,
                switchoverFactors: camera.virtualDeviceSwitchOverVideoZoomFactors
            )
        }
        
        searchContainerHeightC.constant = 100
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



