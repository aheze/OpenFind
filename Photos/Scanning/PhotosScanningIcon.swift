//
//  PhotosScanningIcon.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/18/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import SwiftUI
class PhotosScanningIconController: UIViewController {
    var model: PhotosViewModel
    init(model: PhotosViewModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        /**
         Instantiate the base `view`.
         */
        view = UIView()
        view.backgroundColor = .clear
        
        let containerView = PhotosScanningIcon(model: model)
        let hostingController = UIHostingController(rootView: containerView)
        hostingController.view.frame = view.bounds
        hostingController.view.backgroundColor = .clear
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        view.isUserInteractionEnabled = false
    }
}

struct PhotosScanningIcon: View {
    @ObservedObject var model: PhotosViewModel
    
    var body: some View {
        Button {
            print("Tapped!")
        } label: {
            Circle()
                .trim(from: 0, to: getTrimPercentage())
                .stroke(
                    Color.accent,
                    style: StrokeStyle(
                        lineWidth: 2.5,
                        lineCap: .round
                    )
                )
                .background(
                    Circle()
                        .stroke(
                            Color.accent.opacity(0.25),
                            style: StrokeStyle(
                                lineWidth: 2.5,
                                lineCap: .round
                            )
                        )
                )
        }
    }
    
    func getTrimPercentage() -> CGFloat {
        return CGFloat(model.scanningState.scannedPhotosCount) / CGFloat(model.scanningState.totalPhotosCount)
    }
}
