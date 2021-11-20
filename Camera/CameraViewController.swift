//
//  CameraViewController.swift
//  Camera
//
//  Created by Zheng on 11/18/21.
//

import SwiftUI

public class CameraViewController: UIViewController, PageViewController {
    public var tabType: TabState = .camera
    var cameraViewModel: ToolbarViewModel.Camera!
    
    
    @IBOutlet weak var zoomContainerView: UIView!
    @IBOutlet weak var zoomContainerHeightC: NSLayoutConstraint!
    
    public lazy var toolbar: CameraToolbarView = {
        self.cameraViewModel = .init()
        return CameraToolbarView(viewModel: cameraViewModel)
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    
        print("Camera loaded")
        let zoomView = ZoomView()
        let hostingController = UIHostingController(rootView: zoomView)
        addChild(hostingController, in: zoomContainerView)
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
