//
//  PhotosViewModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Photos
import UIKit

class PhotosViewModel: ObservableObject {
    var realmModel: RealmModel
    var assets: PHFetchResult<PHAsset>?
    var photos = [Photo]()
    var sections = [PhotosSection]()

    /// store the cell images
    var photoToThumbnail = [Photo: UIImage?]()

    /// update the collection view. Set inside `PhotosVC+Listen`
    var reload: (() -> Void)?

    /// PHAsset caching
    let imageManager = PHCachingImageManager()
    var previousPreheatRect = CGRect.zero

    /// for use inside the slides' `willDisplay` cell - hide the container view if animating.
    var animatingSlides = false
    
    /// the slides' current status
    var slidesState: PhotosSlidesState?
    
    /// the state of the results.
    var resultsState: PhotosResultsState?

    /// about to present slides, set the transition
    var transitionAnimatorsUpdated: ((PhotosViewController, PhotosSlidesViewController) -> Void)?

    /// the photo manager got an image, update the transition image view's image.
    var imageUpdatedWhenPresentingSlides: ((UIImage?) -> Void)?

    var scanningIconTapped: (() -> Void)?
    var photosToScan = [Photo]()
    @Saved(Defaults.scanOnLaunch.0) var scanOnLaunch = Defaults.scanOnLaunch.1
    @Saved(Defaults.scanInBackground.0) var scanInBackground = Defaults.scanInBackground.1
    @Saved(Defaults.scanWhileCharging.0) var scanWhileCharging = Defaults.scanWhileCharging.1
    @Published var scanningState = ScanningState.dormant
    @Published var scannedPhotosCount = 0
    @Published var totalPhotosCount = 0

    init(realmModel: RealmModel) {
        self.realmModel = realmModel
        listenToRealm()
    }

    enum ScanningState {
        case dormant
        case scanning
    }
}

extension PhotosViewModel {
    func updatePhotoMetadata(photo: Photo, metadata: PhotoMetadata) {
        if
            let index = getPhotoIndex(photo: photo),
            let indexPath = getPhotoIndexPath(photo: photo)
        {
            photos[index].metadata = metadata
            sections[indexPath.section].photos[indexPath.item].metadata = metadata
        }
    }

    /// get from `photos`
    func getPhotoIndex(photo: Photo) -> Int? {
        if let firstIndex = photos.firstIndex(of: photo) {
            return firstIndex
        }
        return nil
    }

    /// get from `sections`
    func getPhotoIndexPath(photo: Photo) -> IndexPath? {
        for sectionIndex in sections.indices {
            if let photoIndex = sections[sectionIndex].photos.firstIndex(of: photo) {
                return IndexPath(item: photoIndex, section: sectionIndex)
            }
        }
        return nil
    }

    func getFullImage(from photo: Photo) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            imageManager.requestImage(
                for: photo.asset,
                targetSize: .zero,
                contentMode: .aspectFit,
                options: options
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }

    /// closure-based for immediate return
    func getFullImage(from photo: Photo, completion: @escaping ((UIImage?) -> Void)) {
        imageManager.requestImage(
            for: photo.asset,
            targetSize: .zero,
            contentMode: .aspectFit,
            options: nil
        ) { image, _ in
            completion(image)
        }
    }
}

extension PHAsset {
    func getDateCreatedCategorization() -> PhotosSection.Categorization? {
        if
            let components = creationDate?.get(.year, .month, .day),
            let year = components.year, let month = components.month, let day = components.day
        {
            let categorization = PhotosSection.Categorization.date(year: year, month: month, day: day)
            return categorization
        }
        return nil
    }
}
