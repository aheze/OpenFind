//
//  PhotosSlidesVC+Deletion.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/26/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Foundation

extension PhotosSlidesViewController {
    /// called when scrollview stops scrolling, so check if a deletion is really needed (`slidesTargetIndexBeforeDeletion` is not nil)
    func reloadAfterDeletion() {
        guard
            let slidesTargetIndexBeforeDeletion = model.slidesTargetIndexBeforeDeletion,
            let slidesTargetIndexAfterDeletion = model.slidesTargetIndexAfterDeletion
        else { return }

        /// update the current photo

        print("Current: \(self.model.slidesState?.currentPhoto?.asset.localIdentifier)")
        self.model.slidesState?.currentPhoto = self.model.slidesState?.findPhotos[safe: slidesTargetIndexAfterDeletion]?.photo
        print("Changed ro: \(self.model.slidesState?.currentPhoto?.asset.localIdentifier)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let indexPath = slidesTargetIndexBeforeDeletion.indexPath
            print("scrolling to \(indexPath)")
            

            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }

    func finishDeleting() {
        if let slidesTargetIndexAfterDeletion = model.slidesTargetIndexAfterDeletion {
            print("updating -> \(slidesTargetIndexAfterDeletion)")
            print("NOW: \(self.model.slidesState?.currentPhoto?.asset.localIdentifier). Findphotos: \(self.model.slidesState?.findPhotos.map { $0.photo.asset.localIdentifier })")
            print("get? \(self.model.slidesState?.getCurrentFindPhoto()?.photo.asset.localIdentifier)")
            update(animate: false)
            collectionView.layoutIfNeeded()
            DispatchQueue.main.async {
                self.collectionView.scrollToItem(at: slidesTargetIndexAfterDeletion.indexPath, at: .centeredHorizontally, animated: false)
            }

            model.slidesTargetIndexBeforeDeletion = nil
            model.slidesTargetIndexAfterDeletion = nil
        }
    }
}
