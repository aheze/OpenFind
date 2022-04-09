//
//  CameraVC+Toolbar.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Popovers
import SwiftUI

extension CameraViewController {
    func presentStatusView() {
        var popover = Popover(attributes: .init()) { [weak self] in
            if let self = self {
                CameraStatusView(model: self.model)
            }
        }

        if model.toolbarState == .inTabBar {
            withAnimation(
                .spring(response: 0.4, dampingFraction: 0.8, blendDuration: 1)
            ) {
                model.resultsOn = true
                zoomViewModel.alignment = .right
            }
        }
        popover.attributes.sourceFrame = { [weak safeView] in
            safeView?.windowFrame() ?? .zero
        }
        popover.attributes.screenEdgePadding = view.safeAreaInsets
        popover.attributes.sourceFrameInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        popover.attributes.position = .relative(popoverAnchors: [.bottomLeft])

        popover.attributes.rubberBandingMode = .none
        popover.attributes.presentation.animation = .spring()
        popover.attributes.presentation.transition = .opacity
        popover.attributes.dismissal.animation = .spring()
        popover.attributes.dismissal.transition = .opacity
        popover.attributes.dismissal.excludedFrames = { [weak self] in
            [
                self?.view.window?.frameTagged(CameraStatusConstants.sourceViewIdentifier) ?? .zero,
                self?.view.window?.frameTagged(CameraStatusConstants.landscapeSourceViewIdentifier) ?? .zero
            ]
        }
        popover.attributes.tag = CameraStatusConstants.statusViewIdentifier
        popover.attributes.onDismiss = { [weak self] in
            guard let self = self else { return }
            self.resetStatusViewState()
        }

        if let oldPopover = self.popover(tagged: CameraStatusConstants.statusViewIdentifier) {
            replace(oldPopover, with: popover)
        } else {
            present(popover)
        }
    }

    func hideStatusView() {
        if let oldPopover = popover(tagged: CameraStatusConstants.statusViewIdentifier) {
            oldPopover.dismiss()
        }
        resetStatusViewState()
    }

    func resetStatusViewState() {
        withAnimation {
            model.resultsOn = false /// make the icon inactive again
            zoomViewModel.alignment = .center
        }
    }
}
