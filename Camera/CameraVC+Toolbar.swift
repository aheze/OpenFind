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
            withAnimation {
                self.model.resultsOn = false /// make the icon inactive again
            }
        }
        
        if let oldPopover = self.popover(tagged: CameraStatusConstants.statusViewIdentifier) {
            replace(oldPopover, with: popover)
        } else {
            present(popover)
        }
    }
    
    func hideStatusView() {
        if let oldPopover = self.popover(tagged: CameraStatusConstants.statusViewIdentifier) {
            oldPopover.dismiss()
        }
    }

    func presentMessagesViewIfNeeded() {
//        if !model.showingMessageView {
//            model.showingMessageView = true
//
//            var popover = Popover { [weak self] in
//                if let self = self {
//                    CameraMessagesView(model: self.messagesViewModel)
//                }
//            } background: {
//                CameraMessagesBackground()
//            }
//            popover.attributes.tag = "Messages Popover"
//            popover.attributes.sourceFrame = { [weak view] in
//                view?.window?.frameTagged("ResultsIconView") ?? .zero
//            }
//            popover.attributes.sourceFrameInset.top = -(ZoomConstants.containerHeight + 16)
//            popover.attributes.position = .absolute(originAnchor: .top, popoverAnchor: .bottom)
//            popover.attributes.onDismiss = { [weak self] in
//                self?.model.showingMessageView = false
//            }
//
//            present(popover)
//        }
    }

    func hideMessagesViewIfNeeded() {
//        if messagesViewModel.messages.count == 0 {
//            if model.showingMessageView {
//                model.showingMessageView = false
//                if let popover = popover(tagged: "Messages Popover") {
//                    dismiss(popover)
//                }
//            }
//        }
    }

    func showNoTextRecognized() {
        let id = Message.Identifier.noTextDetected
        let message = Message(id: id, string: "No Text Detected") { [weak self] in
            guard let self = self else { return }
            self.messagesViewModel.removeMessage(id: id)
        }
        messagesViewModel.addMessage(message)
        presentMessagesViewIfNeeded()
    }

    func hideNoTextRecognized() {
        let id = Message.Identifier.noTextDetected
        messagesViewModel.removeMessage(id: id)
        hideMessagesViewIfNeeded()
    }
}
