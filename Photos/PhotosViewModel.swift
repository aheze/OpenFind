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
    // MARK: Base collection view

    var realmModel: RealmModel
    var assets: PHFetchResult<PHAsset>?
    var photos = [Photo]()
    var sections = [PhotosSection]()

    /// store the cell images
    var photoToThumbnail = [Photo: UIImage?]()

    /// update the entire collection view. Set inside `PhotosVC+Listen`
    var reload: (() -> Void)?

    /// reload at a specific index path
    /// 1. Index path inside `collectionView`
    /// 2. Index inside `resultsCollectionView`
    /// 3. the photo metadata
    var reloadAt: ((IndexPath?, Int?, PhotoMetadata) -> Void)?

    /// PHAsset caching
    let imageManager = PHCachingImageManager()
    var previousPreheatRect = CGRect.zero

    // MARK: Filtering

    var sliderViewModel = SliderViewModel()

    // MARK: Slides / Results

    /// for use inside the slides' `willDisplay` cell - hide the container view if animating.
    var animatingSlides = false

    /// the slides' current status
    @Published var slidesState: PhotosSlidesState?

    /// the state of the results.
    var resultsState: PhotosResultsState?

    /// the date when the last results update occurred.
    var lastResultsUpdateTime: Date?

    /// about to present slides, update the slides search collection view to match the latest search view model
    /// Set this inside **PhotosController**
    /// Must call `replaceInPlace` first
    var updateSlidesSearchCollectionView: (() -> Void)?

    /// about to present slides, set the transition
    var transitionAnimatorsUpdated: ((PhotosViewController, PhotosSlidesViewController) -> Void)?

    /// the photo manager got an image, update the transition image view's image.
    var imageUpdatedWhenPresentingSlides: ((UIImage?) -> Void)?

    /// update the color/alpha with those of the specified fields
    var updateFieldOverrides: (([Field]) -> Void)?

    // MARK: Find from just-scanned photos

    /// sentences were recently added to these photos, but not applied to the main model yet.
    var photosWithQueuedSentences = [Photo]()

    /// if true, a sentences update is scheduled and should be applied ASAP.
    var updateState: PhotosSentencesUpdateState?

    /// set to false if finger is still touching
    var updateAllowed = true {
        didSet {
            if updateAllowed, updateState == .waitingForPermission {
                addQueuedSentencesToMetadatas()
            }
        }
    }

    /// sentences were applied! find inside them now and append to `resultsState` / `slidesState`.
    var photosWithQueuedSentencesAdded: (([Photo]) -> Void)?

    // MARK: Scanning

    var scanningIconTapped: (() -> Void)?
    var photosToScan = [Photo]()
    @Saved(Defaults.scanOnLaunch.0) var scanOnLaunch = Defaults.scanOnLaunch.1
    @Saved(Defaults.scanInBackground.0) var scanInBackground = Defaults.scanInBackground.1
    @Saved(Defaults.scanWhileCharging.0) var scanWhileCharging = Defaults.scanWhileCharging.1
    @Published var scanningState = ScanningState.dormant
    @Published var scannedPhotosCount = 0
    @Published var totalPhotosCount = 0

    // MARK: Selection

    @Published var isSelecting = false
    @Published var selectedPhotos = [Photo]()

    /// reload the collection view to make it empty
    var updateSearchCollectionView: (() -> Void)?
    var deleteSelected: (() -> Void)?

    init(realmModel: RealmModel) {
        self.realmModel = realmModel
        listenToRealm()
    }

    enum ScanningState {
        case dormant
        case scanningAllPhotos
    }
}

extension PhotosViewModel {
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

    /// get from `sections`
    func getPhoto(from metadata: PhotoMetadata) -> Photo? {
        let photo = photos.first { $0.asset.localIdentifier == metadata.assetIdentifier }
        return photo
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
