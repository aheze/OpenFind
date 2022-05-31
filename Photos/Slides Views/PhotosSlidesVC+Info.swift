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
        let infoModel = PhotoSlidesInfoViewModel()
        infoModel.showHandle = true
        infoModel.reportSize = true
        let viewController = PhotosSlidesInfoViewController(model: model, realmModel: realmModel, infoModel: infoModel, textModel: infoNoteTextViewModel)
        addChildViewController(viewController, in: infoViewContainer)
        infoViewContainer.clipsToBounds = true

        scrollView.isScrollEnabled = false
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive

        infoModel.sizeChanged = { [weak self] size in
            guard let self = self else { return }

            let infoHeight = self.getInfoHeight() /// max height
            self.infoViewContainerHeightC.constant = max(infoHeight, size.height + self.tabViewModel.tabBarAttributes.backgroundHeight + 40)
        }

        infoModel.noteChanged = { [weak self] in
            guard let self = self else { return }

            Debouncer.debounce(queue: .main) {
                self.model.updateDisplayedResults?()
            }
        }

        infoNoteTextViewModel.$keyboardHeight
            .dropFirst()
            .sink { [weak self] height in
                guard let self = self else { return }
                guard self.model.slidesState?.toolbarInformationOn ?? false else { return }
                let bottomPadding = height ?? 0

                UIView.animate(withDuration: 0.5) {
                    if height != nil {
                        self.scrollView.contentOffset.y += PhotosSlidesConstants.notesHeight
                    }

                    self.scrollView.contentInset.bottom = bottomPadding
                    self.scrollView.verticalScrollIndicatorInsets.bottom = bottomPadding
                }
            }
            .store(in: &realmModel.cancellables)
    }

    func getInfoHeight() -> CGFloat {
        let height = PhotosSlidesConstants.infoHeightPercentageOfScreen * view.bounds.height
        return height
    }

    func showInfo(_ show: Bool) {
        var offset: CGFloat?
        var percentage = CGFloat(0)

        if show {
            /// landscape iPhone or iPad
            if traitCollection.horizontalSizeClass == .regular {
                guard popover(tagged: "Info Popover") == nil else { return }

                var attributes = Popover.Attributes()
                attributes.tag = "Info Popover"
                attributes.position = .relative(popoverAnchors: [.topRight])
                attributes.dismissal.mode = .none

                let navigationBarHeight = getCompactBarSafeAreaHeight(with: Global.safeAreaInsets) + slidesSearchViewModel.getTotalHeight()
                let tabBarHeight = tabViewModel.tabBarAttributes.backgroundHeight

                attributes.rubberBandingMode = .none
                attributes.sourceFrameInset = UIEdgeInsets(top: navigationBarHeight + 16, left: 16, bottom: tabBarHeight + 16, right: 16)
                attributes.screenEdgePadding = UIEdgeInsets(top: navigationBarHeight + 16, left: 16, bottom: tabBarHeight + 16, right: 16)
                attributes.sourceFrame = { [weak self] in
                    guard let self = self else { return .zero }
                    return self.view.bounds
                }

                let infoModel = PhotoSlidesInfoViewModel()
                infoModel.noteChanged = { [weak self] in
                    guard let self = self else { return }

                    Debouncer.debounce(queue: .main) {
                        self.model.updateDisplayedResults?()
                    }
                }
                let infoNoteTextViewModel = EditableTextViewModel(configuration: .infoSlides)

                let popover = Popover(attributes: attributes) { [weak self] in
                    if let self = self {
                        ScrollView {
                            PhotosSlidesInfoView(
                                model: self.model,
                                realmModel: self.realmModel,
                                infoModel: infoModel, /// default configuration
                                textModel: infoNoteTextViewModel
                            )
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
                dismissPanGesture.isEnabled = false
                scrollView.isScrollEnabled = true
                offset = getInfoHeight()
                percentage = 1
            }
        } else {
            offset = 0
            percentage = 0
            resetInfoToHidden(scrollIfNeeded: false)
            collectionViewContainerHeightC.constant = view.bounds.height
        }

        /// first make sure image resizes
        flowLayout.invalidateLayout()
        UIView.animate(duration: 0.6, dampingFraction: 1) {
            self.scrollView.contentOffset = CGPoint(x: 0, y: offset ?? 0)

            /// don't also call `self.flowLayout.invalidateLayout()`, otherwise there will be a glitch
            /// `currentViewController.setAspectRatio(scaleToFill: show)` also seems to be automatically animated
            self.scrollView.layoutIfNeeded()

            self.getCurrentItemViewController()?.setAspectRatioToFill(percentage: percentage)
        }
    }

    /// set constraints to 0
    func resetInfoToHidden(scrollIfNeeded: Bool) {
        model.slidesState?.toolbarInformationOn = false
        dismissPanGesture.isEnabled = true
        scrollView.isScrollEnabled = false
        infoNoteTextViewModel.endEditing?()
        if let popover = view.popover(tagged: "Info Popover") {
            popover.dismiss()
        }

        if scrollIfNeeded {
            collectionViewContainerHeightC.constant = view.bounds.height

            flowLayout.invalidateLayout()
            UIView.animate(duration: 0.6, dampingFraction: 1) {
                self.scrollView.contentOffset = CGPoint(x: 0, y: 0)

                /// don't also call `self.flowLayout.invalidateLayout()`, otherwise there will be a glitch
                /// `currentViewController.setAspectRatio(scaleToFill: show)` also seems to be automatically animated
                self.scrollView.layoutIfNeeded()
            }
        }
    }
}
