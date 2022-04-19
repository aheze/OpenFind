//
//  SearchVC+Extras.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/19/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Popovers
import SwiftUI

extension SearchViewController {
    static let extrasPopoverTag = "Extras"
    func checkExtras(text: String) {
        if text.roughlyEquals("/resetlaunch") {
            realmModel.launchedBefore = false
            showCheck(configuration: .checkmark(message: "Launch Reset"), autoDismiss: true)
        }

        if text.roughlyEquals("/about") {
            showCheck(configuration: .about, autoDismiss: false)
        }

        if text.roughlyEquals("/help") {
            view.endEditing(true)
            if let viewController = SettingsData.getHelpCenter?() {
                present(viewController, animated: true)
            }
        }
    }

    func showCheck(configuration: ExtrasView.Configuration, autoDismiss: Bool) {
        var attributes = Popover.Attributes()
        attributes.tag = SearchViewController.extrasPopoverTag
        attributes.position = .relative(popoverAnchors: [.top])
        attributes.sourceFrame = { UIScreen.main.bounds }

        var insets = Global.safeAreaInsets
        insets.top += 160
        attributes.sourceFrameInset = insets
        let popover = Popover(attributes: attributes) {
            ExtrasView(configuration: configuration)
        }
        if let existingPopover = view.popover(tagged: SearchViewController.extrasPopoverTag) {
            replace(existingPopover, with: popover)
        } else {
            present(popover)
        }

        if autoDismiss {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                if let existingPopover = self.view.popover(tagged: SearchViewController.extrasPopoverTag) {
                    self.dismiss(existingPopover)
                }
            }
        }
    }
}

struct ExtrasView: View {
    enum Configuration {
        case checkmark(message: String)
        case about
    }

    var configuration: Configuration

    @State var transform: SettingsProfileTransformState?
    var body: some View {
        switch configuration {
        case .checkmark(message: let message):
            VStack(spacing: 20) {
                Image(systemName: "checkmark")
                    .font(UIFont.systemFont(ofSize: 52, weight: .semibold).font)
                Text(message)
                    .font(UIFont.preferredCustomFont(forTextStyle: .title3, weight: .medium).font)
            }
            .padding(36)
            .background(VisualEffectView(.regular))
            .cornerRadius(20)
        case .about:
            VStack(spacing: 16) {
                Button {
                    withAnimation(
                        .spring(
                            response: 0.6,
                            dampingFraction: 0.6,
                            blendDuration: 1
                        )
                    ) {
                        if transform == nil {
                            transform = SettingsProfileTransformState.allCases.randomElement()
                        } else {
                            transform = nil
                        }
                    }
                } label: {
                    PortraitView(length: 180, circular: true, transform: $transform)
                }
                .buttonStyle(LaunchButtonStyle())

                Group {
                    Text("An Andrew Zheng Production")

                    Button {
                        if let url = URL(string: "https://twitter.com/intent/user?screen_name=aheze0") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Text("Follow me on Twitter!")
                            .opacity(0.75)
                    }
                }
                .font(UIFont.preferredCustomFont(forTextStyle: .title3, weight: .medium).font)
                .foregroundColor(.white)
            }
            .padding(36)
            .background(VisualEffectView(.regular))
            .cornerRadius(20)
        }
    }
}

private extension String {
    func roughlyEquals(_ otherText: String) -> Bool {
        let a = trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let b = otherText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return a == b
    }
}
