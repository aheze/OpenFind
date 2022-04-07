//
//  PhotosSlidesVC+Deletion.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/26/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension PhotosSlidesViewController {
    func delete(photo: Photo) {
        guard let slidesState = model.slidesState else { return }
        guard let currentIndex = slidesState.getCurrentIndex() else { return }

        var targetIndexAfterDeletion: Int?
        if slidesState.slidesPhotos.count == 1 { /// last photo. After deletion, go back to the collection view.
            targetIndexAfterDeletion = nil
        } else if currentIndex == slidesState.slidesPhotos.count - 1 { /// rightmost photo
            /// no need for this actually, will already be scrolled here.
            /// But `reloadAfterDeletion` checks for both `slidesTargetIndexBeforeDeletion` and `slidesTargetIndexAfterDeletion` being not nil,
            /// so set this too.
            targetIndexAfterDeletion = currentIndex - 1
        } else {
            targetIndexAfterDeletion = currentIndex
        }

        var slidesPhotos = [SlidesPhoto]()
        if let currentSlidesPhotos = self.model.slidesState?.slidesPhotos {
            for index in currentSlidesPhotos.indices {
                var slidesPhoto = currentSlidesPhotos[index]
                if slidesPhoto.findPhoto.photo != photo {
                    slidesPhoto.id = UUID()
                    slidesPhotos.append(slidesPhoto)
                }
            }
        }

        model.slidesState?.slidesPhotos = slidesPhotos

        /// need to manually update photo
        if let targetIndexAfterDeletion = targetIndexAfterDeletion {
            model.slidesState?.currentPhoto = self.model.slidesState?.slidesPhotos[safe: targetIndexAfterDeletion]?.findPhoto.photo
        } else {
            self.navigationController?.popViewController(animated: true)
        }

        DispatchQueue.main.async {
            if let cell = self.collectionView.cellForItem(at: currentIndex.indexPath) as? PhotosSlidesContentCell {
                cell.contentView.transform = .identity
                UIView.animate(
                    duration: 0.5,
                    dampingFraction: 0.9
                ) {
                    cell.viewController?.view.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
                    cell.viewController?.view.alpha = 0
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.update(animate: true)

                if
                    let targetIndexAfterDeletion = targetIndexAfterDeletion,
                    let cell = self.collectionView.cellForItem(at: targetIndexAfterDeletion.indexPath) as? PhotosSlidesContentCell
                {
                    cell.contentView.transform = CGAffineTransform(translationX: cell.contentView.bounds.width, y: 0)
                    UIView.animate(
                        duration: 0.35,
                        dampingFraction: 1
                    ) {
                        cell.contentView.transform = .identity
                    }
                }
            }
        }
    }
}
