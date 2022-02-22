//
//  CameraVC+Toolbar.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Popovers
import UIKit

extension CameraViewController {
    func presentMessagesViewIfNeeded() {
        if !model.showingMessageView {
            model.showingMessageView = true

            var popover = Popover { [weak self] in
                if let self = self {
                    CameraMessagesView(model: self.messagesViewModel)
                }
            } background: {
                CameraMessagesBackground()
            }
            popover.attributes.tag = "Messages Popover"
            popover.attributes.sourceFrame = { [weak view] in
                view?.window?.frameTagged("ResultsIconView") ?? .zero
            }
            popover.attributes.sourceFrameInset.top = -(ZoomConstants.containerHeight + 16)
            popover.attributes.position = .absolute(originAnchor: .top, popoverAnchor: .bottom)
            popover.attributes.onDismiss = { [weak self] in
                self?.model.showingMessageView = false
            }

            present(popover)
        }
    }

    func hideMessagesViewIfNeeded() {
        if messagesViewModel.messages.count == 0 {
            if model.showingMessageView {
                model.showingMessageView = false
                if let popover = self.popover(tagged: "Messages Popover") {
                    dismiss(popover)
                }
            }
        }
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
