//
//  PhotosSlidesVC+VoiceOver.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/20/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

extension PhotosSlidesViewController {
    func setupVoiceOverToolbar() {
        let toolbar = PhotosSlidesVoiceOverToolbar(
            model: model,
            tabViewModel: tabViewModel
        ) { [weak self] in
            guard let self = self else { return }
            self.voiceOverToolbarIncrement()
        } decrement: { [weak self] in
            guard let self = self else { return }
            self.voiceOverToolbarDecrement()
        } sizeChanged: { [weak self] size in
            guard let self = self else { return }
            self.collectionViewToolbarHeightC.constant = size.height
        }
        let hostingController = UIHostingController(rootView: toolbar)
        addChildViewController(hostingController, in: collectionViewToolbarContainer)
        collectionViewToolbarContainer.backgroundColor = .clear
        hostingController.view.backgroundColor = .clear

        listen(
            to: UIAccessibility.voiceOverStatusDidChangeNotification.rawValue,
            selector: #selector(updateVoiceOver)
        )

        updateVoiceOver()
    }

    @objc func updateVoiceOver() {
        if UIAccessibility.isVoiceOverRunning {
            collectionViewToolbarContainer.alpha = 1
        } else {
            collectionViewToolbarContainer.alpha = 0
        }
    }

    func voiceOverToolbarIncrement() {
        guard
            let slidesState = model.slidesState,
            let currentIndex = slidesState.getCurrentIndex()
        else { return }

        if currentIndex < slidesState.slidesPhotos.count - 1 {
            let nextIndex = currentIndex + 1
            model.slidesState?.currentPhoto = slidesState.slidesPhotos[safe: nextIndex]?.findPhoto.photo
            model.slidesCurrentPhotoChanged?()
            collectionView.scrollToItem(at: nextIndex.indexPath, at: .centeredHorizontally, animated: false)
            if
                let cell = collectionView.cellForItem(at: nextIndex.indexPath) as? PhotosSlidesContentCell,
                let viewController = cell.viewController
            {
                viewController.containerView.alpha = 1
            }
        }
    }

    func voiceOverToolbarDecrement() {
        guard
            let slidesState = model.slidesState,
            let currentIndex = slidesState.getCurrentIndex()
        else { return }

        if currentIndex > 0 {
            let previousIndex = currentIndex - 1
            model.slidesState?.currentPhoto = slidesState.slidesPhotos[safe: previousIndex]?.findPhoto.photo
            model.slidesCurrentPhotoChanged?()
            collectionView.scrollToItem(at: previousIndex.indexPath, at: .centeredHorizontally, animated: false)
            if
                let cell = collectionView.cellForItem(at: previousIndex.indexPath) as? PhotosSlidesContentCell,
                let viewController = cell.viewController
            {
                viewController.containerView.alpha = 1
            }
        }
    }
}
