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
        withAnimation {
            self.zoomViewModel.alignment = .right
        }

        var popover = Popover(attributes: .init()) { [weak self] in
            if let self = self {
                CameraStatusView(model: self.model)
            }
        }

        popover.attributes.sourceFrame = { [weak view] in
            view?.window?.frameTagged(CameraStatusConstants.sourceViewIdentifier) ?? .zero
        }
        popover.attributes.sourceFrameInset.top = -32 /// past the space between the button and the tab bar + extra padding
        popover.attributes.position = .absolute(originAnchor: .top, popoverAnchor: .bottom)
        popover.attributes.rubberBandingMode = .none
        popover.attributes.presentation.animation = .spring()
        popover.attributes.presentation.transition = .opacity
        popover.attributes.dismissal.animation = .spring()
        popover.attributes.dismissal.transition = .opacity
        popover.attributes.dismissal.excludedFrames = { [weak self] in
            [
                self?.view.window?.frameTagged(CameraStatusConstants.sourceViewIdentifier) ?? .zero
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
