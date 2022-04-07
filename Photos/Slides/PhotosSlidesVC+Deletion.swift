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
        
        var slidesPhotos = [SlidesPhoto]()
        if let currentSlidesPhotos = self.model.slidesState?.slidesPhotos {
            for index in currentSlidesPhotos.indices {
                var slidesPhoto = currentSlidesPhotos[index]
                if slidesPhoto.findPhoto.photo != photoToDelete {
                    slidesPhoto.id = UUID()
                    slidesPhotos.append(slidesPhoto)
                }
            }
        }
        
        self.model.slidesState?.slidesPhotos = slidesPhotos

        update(animate: true)
//        DispatchQueue.main.async {
//            self.collectionView.isUserInteractionEnabled = false
//            print("deleting at \(currentIndex.indexPath)")
//            if let cell = self.collectionView.cellForItem(at: currentIndex.indexPath) as? PhotosSlidesContentCell {
//                cell.contentView.transform = .identity
//                UIView.animate(
//                    duration: 0.6,
//                    dampingFraction: 0.9
//                ) {
//                    cell.contentView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
//                    cell.contentView.alpha = 0
//                }
//            }
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                self.collectionView.isUserInteractionEnabled = true
//                if let targetIndexBeforeDeletion = targetIndexBeforeDeletion {
//                    self.collectionView.scrollToItem(at: targetIndexBeforeDeletion.indexPath, at: .centeredHorizontally, animated: true)
//                } else {
//                    self.navigationController?.popViewController(animated: true)
//                }
//            }
//        }
    }

//    func finishDeleting() {
//        guard let photoToDelete = photoToDelete else { return }
////        self.model.slidesState?.slidesPhotos = self.model.slidesState?.slidesPhotos.filter { $0.findPhoto.photo != photoToDelete } ?? []
//
//        var slidesPhotos = [SlidesPhoto]()
//        if let currentSlidesPhotos = self.model.slidesState?.slidesPhotos {
//            for index in currentSlidesPhotos.indices {
//                var slidesPhoto = currentSlidesPhotos[index]
//                if slidesPhoto.findPhoto.photo != photoToDelete {
//                    slidesPhoto.id = UUID()
//                    slidesPhotos.append(slidesPhoto)
//                }
//            }
//        }
//
//        self.model.slidesState?.slidesPhotos = slidesPhotos
//
//        update(animate: true)
////        update(animate: false)
////        self.collectionView.layoutIfNeeded()
////
////        print("updatied,.")
////        if let targetIndexAfterDeletion = targetIndexAfterDeletion {
////            print("target... \(targetIndexAfterDeletion)")
////            let oneBefore = targetIndexAfterDeletion - 1
////            let oneAfter = targetIndexAfterDeletion + 1
////
////            for index in [oneBefore, targetIndexAfterDeletion, oneAfter] {
////                if let cell = self.collectionView.cellForItem(at: index.indexPath) as? PhotosSlidesContentCell {
////                    print("exists \(index)")
////                    display(cell: cell, indexPath: index.indexPath)
//////                    cell.contentView.transform = .identity
//////                    UIView.animate(
//////                        duration: 0.6,
//////                        dampingFraction: 0.9
//////                    ) {
//////                        cell.contentView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
//////                        cell.contentView.alpha = 0
//////                    }
////                }
////            }
////        }
//
////        if let targetIndexAfterDeletion = targetIndexAfterDeletion {
////            self.model.slidesState?.currentPhoto = self.model.slidesState?.slidesPhotos[safe: targetIndexAfterDeletion]?.findPhoto.photo
////
////            DispatchQueue.main.async {
////                self.collectionView.layoutIfNeeded()
////                self.collectionView.scrollToItem(at: targetIndexAfterDeletion.indexPath, at: .centeredHorizontally, animated: false)
////
////
////            }
////
////            self.targetIndexAfterDeletion = nil
////        }
//    }
}
