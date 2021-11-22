//
//  CameraViewController.swift
//  Camera
//
//  Created by Zheng on 11/18/21.
//

import SwiftUI
import Combine

public class CameraViewController: UIViewController, PageViewController {
    
    public var tabType: TabState = .camera
    var cameraViewModel: ToolbarViewModel.Camera!
    var zoomViewModel: ZoomViewModel!
    private var cancellable: AnyCancellable?
    
    @IBOutlet weak var zoomContainerView: UIView!
    @IBOutlet weak var zoomContainerHeightC: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var livePreviewContainerView: UIView!
    lazy var livePreviewViewController: LivePreviewViewController = {
        let storyboard = UIStoryboard(name: "CameraContent", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "LivePreviewViewController") as! LivePreviewViewController
        self.addChild(viewController, in: livePreviewContainerView)
        
        viewController.findFromPhotosButtonPressed = { [weak self] in
            TabControl.moveToOtherTab?(.photos, true)
        }
        return viewController
    }()
    
    public lazy var toolbar: CameraToolbarView = {
        self.cameraViewModel = .init()
        return CameraToolbarView(viewModel: cameraViewModel)
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    
        print("Camera loaded")
        self.zoomViewModel = .init(containerView: zoomContainerView)
        let zoomView = ZoomView(zoomViewModel: self.zoomViewModel)
        let hostingController = UIHostingController(rootView: zoomView)
        zoomContainerView.backgroundColor = .clear
        hostingController.view.backgroundColor = .clear
        addChild(hostingController, in: zoomContainerView)
        
        view.backgroundColor = .black
        cancellable = zoomViewModel.$zoom.sink { zoom in
            UIView.animate(withDuration: 0.5) {
                self.imageView.transform = CGAffineTransform(scaleX: zoom, y: zoom)
            }
        }
        
        _ = livePreviewViewController
    }
}

extension CameraViewController {
    public func willBecomeActive() {
        
    }
    
    public func didBecomeActive() {
        
    }
    
    public func willBecomeInactive() {
        
    }
    
    public func didBecomeInactive() {
            
    }
}

public struct CameraToolbarView: View {
    @ObservedObject var viewModel: ToolbarViewModel.Camera
    
    public var body: some View {
        HStack(alignment: .top, spacing: 0) {
            HStack {
                ResultsIconView(count: $viewModel.resultsCount)
                Spacer()
                FlashIconView(isOn: $viewModel.flashOn)
            }
            .frame(maxWidth: .infinity)

            Color.clear

            HStack {
                FocusIconView(isOn: $viewModel.focusOn)
                Spacer()
                SettingsIconView()
            }
            .frame(maxWidth: .infinity)
        }
    }
}


