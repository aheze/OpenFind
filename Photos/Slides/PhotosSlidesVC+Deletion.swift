//
//  PhotosSlidesVC+Deletion.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/26/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Foundation

extension PhotosSlidesViewController {
    func delete(photo: Photo) {
        guard let slidesState = model.slidesState else { return }
        guard let currentIndex = slidesState.getCurrentIndex() else { return }

        var targetIndexBeforeDeletion: Int?
        var targetIndexAfterDeletion: Int?
        if slidesState.slidesPhotos.count == 1 { /// last photo. After deletion, go back to the collection view.
            targetIndexBeforeDeletion = nil
            targetIndexAfterDeletion = nil
        } else if currentIndex == slidesState.slidesPhotos.count - 1 { /// rightmost photo
            targetIndexBeforeDeletion = currentIndex - 1

            /// no need for this actually, will already be scrolled here.
            /// But `reloadAfterDeletion` checks for both `slidesTargetIndexBeforeDeletion` and `slidesTargetIndexAfterDeletion` being not nil,
            /// so set this too.
            targetIndexAfterDeletion = currentIndex - 1
        } else {
            targetIndexBeforeDeletion = currentIndex + 1 /// photo slides in from the right
            targetIndexAfterDeletion = currentIndex
        }

        self.photoToDelete = photo
        self.targetIndexAfterDeletion = targetIndexAfterDeletion

        DispatchQueue.main.async {
            if let targetIndexBeforeDeletion = targetIndexBeforeDeletion {
                self.collectionView.scrollToItem(at: targetIndexBeforeDeletion.indexPath, at: .centeredHorizontally, animated: true)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    func finishDeleting() {
        guard let photoToDelete = photoToDelete else { return }
//        print("beofre: \(self.model.slidesState?.findPhotos.count). Deleting: \(photoToDelete.asset.localIdentifier)")
        self.model.slidesState?.slidesPhotos = self.model.slidesState?.slidesPhotos.filter { $0.findPhoto.photo != photoToDelete } ?? []
//        print("after: \(self.model.slidesState?.findPhotos.count)")
        update(animate: false)

//        if let targetIndexAfterDeletion = targetIndexAfterDeletion {
//            print("target: \(targetIndexAfterDeletion)")
//            self.model.slidesState?.currentPhoto = self.model.slidesState?.findPhotos[safe: targetIndexAfterDeletion]?.photo
//
//            DispatchQueue.main.async {
//                self.collectionView.layoutIfNeeded()
//                self.collectionView.scrollToItem(at: targetIndexAfterDeletion.indexPath, at: .centeredHorizontally, animated: false)
//            }
//
//            self.targetIndexAfterDeletion = nil
//        }
    }
}
