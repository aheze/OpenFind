//
//  CameraVC+Setup.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/8/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

extension CameraViewController {
    func setup() {
        setupContent()
        setupHighlights()
        setupProgress()
        setupBlur()
        checkPermissions()
    }

    func setupContent() {
        view.backgroundColor = Colors.accentDarkBackground
        safeView.backgroundColor = .clear
        contentContainerView.backgroundColor = .clear
        scrollZoomContainerView.backgroundColor = .clear
        scrollZoomHookContainerView.backgroundColor = .clear
        simulatedSafeView.backgroundColor = .clear
        simulatedSafeView.isHidden = true
        landscapeToolbarContainer.backgroundColor = .clear
    }

    func checkPermissions() {
        switch permissionsViewModel.currentStatus {
        case .notDetermined:
            showPermissionsView()
        case .restricted:
            showPermissionsView()
        case .denied:
            showPermissionsView()
        case .authorized:
            setupLivePreview()
        @unknown default:
            fatalError()
        }
    }

    func showPermissionsView() {
        livePreviewContainerView.alpha = 0
        zoomContainerView.alpha = 0

        let permissionsView = CameraPermissionsView(model: permissionsViewModel)
        let hostingController = UIHostingController(rootView: permissionsView)
        hostingController.view.backgroundColor = .clear
        addChildViewController(hostingController, in: view)
        view.bringSubviewToFront(hostingController.view)
        permissionsViewModel.permissionsGranted = { [weak self] in
            guard let self = self else { return }
            self.setupLivePreview()

            UIView.animate(withDuration: 0.5) { [weak hostingController] in
                hostingController?.view.alpha = 0
                self.livePreviewContainerView.alpha = 1
                self.zoomContainerView.alpha = 1

            } completion: { [weak hostingController] _ in
                hostingController?.view.removeFromSuperview()
            }
        }
    }

    /// setup after permissions got
    func setupLivePreview() {
        livePreviewViewController = createLivePreview()
        setupZoom()
        setupLandscapeToolbar()
    }
}
