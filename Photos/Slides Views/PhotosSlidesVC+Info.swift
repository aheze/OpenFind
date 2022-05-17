//
//  PhotosSlidesVC+Info.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Popovers
import SwiftUI

extension PhotosSlidesViewController {
    func setupInfo() {
        let viewController = PhotosSlidesInfoViewController(model: model, realmModel: realmModel)
        addChildViewController(viewController, in: infoViewContainer)
        infoViewContainer.clipsToBounds = true
    }

    func getInfoHeight() -> CGFloat {
        let height = PhotosSlidesConstants.infoHeightPercentageOfScreen * view.bounds.height
        return height
    }

    func showInfo(_ show: Bool) {
        var offset: CGFloat?
        if show {
            /// landscape iPhone or iPad
            if traitCollection.verticalSizeClass == .compact {
                var attributes = Popover.Attributes()
                attributes.tag = "Popover"
                attributes.position = .relative(popoverAnchors: [.topRight])
                attributes.dismissal.mode = .none

                let navigationBarHeight = getCompactBarSafeAreaHeight(with: Global.safeAreaInsets) + slidesSearchViewModel.getTotalHeight()
                let tabBarHeight = tabViewModel.tabBarAttributes.backgroundHeight

                attributes.sourceFrameInset = UIEdgeInsets(top: navigationBarHeight + 16, left: 16, bottom: tabBarHeight + 16, right: 16)
                attributes.screenEdgePadding = UIEdgeInsets(top: navigationBarHeight + 16, left: 16, bottom: tabBarHeight + 16, right: 16)
                attributes.sourceFrame = { [weak self] in
                    guard let self = self else { return .zero }
                    return self.view.bounds
                }
                let popover = Popover(attributes: attributes) { [weak self] in
                    if let self = self {
                        ScrollView {
                            PhotosSlidesInfoView(model: self.model, realmModel: self.realmModel)
                        }
                        .background(UIColor.systemBackground.color)
                        .frame(width: 300)
                        .frame(maxHeight: 300)
                        .cornerRadius(16)
                        .popoverShadow()
                    }
                }
                present(popover)
            } else {
                infoViewContainerHeightC.constant = getInfoHeight()
                dismissPanGesture.isEnabled = false
                scrollView.alwaysBounceVertical = true
                offset = getInfoHeight()
            }
        } else {
            resetInfoToHidden()
            offset = 0
        }

        UIView.animate(duration: 0.6, dampingFraction: 1) {
            self.scrollView.contentOffset = CGPoint(x: 0, y: offset ?? 0)

            /// don't also call `self.flowLayout.invalidateLayout()`, otherwise there will be a glitch
            /// `currentViewController.setAspectRatio(scaleToFill: show)` also seems to be automatically animated
            self.scrollView.layoutIfNeeded()
        }
    }

    /// set constraints to 0
    func resetInfoToHidden() {
        model.slidesState?.toolbarInformationOn = false
        infoViewContainerHeightC.constant = 0
        dismissPanGesture.isEnabled = true
        scrollView.alwaysBounceVertical = false
        if let popover = view.popover(tagged: "Popover") {
            popover.dismiss()
        }
    }
}
