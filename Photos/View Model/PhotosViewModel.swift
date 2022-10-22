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

    /// show loading indicator
    @Published var loaded = false
    @Published var emptyContentTopPadding = CGFloat(0) /// search bar offset

    var getRealmModel: (() -> RealmModel)?

    /// all photos and assets
    var assets: PHFetchResult<PHAsset>? /// could become inaccurate after deletion.
    var photos = [Photo]()
    var displayedSections = [PhotosSection]() /// this is fed into the collection view

    @Published var photosEditable = false /// select button enabled

    /// when star/unstar
    var sortNeededAfterStarChanged = false

    /// reload collection views and find.
    var reloadAfterStarChanged: (() -> Void)?

    /// storage
    var starredSections = [PhotosSection]()
    var screenshotsSections = [PhotosSection]()
    var allSections = [PhotosSection]()

    /// update the entire collection view, only called once at first. Set inside `PhotosVC+Listen`
    var reload: (() -> Void)?

    /// reload at a specific index path
    /// 1. Index path inside `collectionView`
    /// 2. Index inside `resultsCollectionView`
    /// 3. the photo metadata
    var reloadAt: ((IndexPath?, Int?, PhotoMetadata) -> Void)?

    /// PHAsset caching
    let imageManager = PHCachingImageManager()
    var previousPreheatRect = CGRect.zero

    // MARK: Observed external changes

    var waitingToAddExternalPhotos = false

    /// photos added from saving in camera
    var photosAddedFromCamera = [Photo]()

    /// reload collection views and find.
    var reloadAfterExternalPhotosChanged: (() -> Void)?

    /// reload the collection view to make it empty
    var updateSearchCollectionView: (() -> Void)?

    /// reload displayed results photos after info changed
    var updateDisplayedResults: (() -> Void)?

    // MARK: Slides

    /// for use inside the slides' `willDisplay` cell - hide the container view if animating.
    var animatingSlides = false

    /// the slides' current status
    @Published var slidesState: PhotosSlidesState?

    /// call these manually, can't be inside struct
    var slidesCurrentPhotoChanged: (() -> Void)?
    var slidesToolbarInformationOnChanged: (() -> Void)?
    var slidesUpdateFullScreenStateTo: ((Bool) -> Void)?

    // MARK: - Finding / Results

    var currentFindingTask: Task<Void, Error>?

    /// the state of the results.
    var resultsState: PhotosResultsState?

    // MARK: - Add results after update allowed

    var waitingToAddResults = false
    var queuedResults = QueuedResults()
    var addQueuedResults: ((QueuedResults) -> Void)?

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

    /// sentences were applied! find inside them now and append to `resultsState` / `slidesState`.
    /// This is called when:
    ///     - **Scenario 1:** Searching inside slides when photo has no metadata yet and `startFinding` called
    ///     - **Scenario 2:** Searching for results in the results screen while scanning photos live
    var photosWithQueuedSentencesAdded: (([Photo]) -> Void)?

    /// if `waitingForPermission`, a sentences update should be applied ASAP
    /// `waitingForPermission` = not allowed at the moment, apply
    var updateState: PhotosSentencesUpdateState?

    /// set to false if finger is still touching
    var updateAllowed = true {
        didSet {
            guard updateAllowed else { return }

            if updateState == .waitingForPermission {
                addQueuedSentencesToMetadatas()
            }

            if waitingToAddResults {
                waitingToAddResults = false
                addQueuedResults?(queuedResults)
                queuedResults = .init()
            }

            if waitingToAddExternalPhotos {
                waitingToAddExternalPhotos = false

                /// also called `addQueuedSentencesToMetadatas`
                loadExternalPhotos()
            }

            if sortNeededAfterStarChanged {
                updateAfterStarChange()
            }
        }
    }

    // MARK: Scanning

    /// call this when pressed "scan now" in info
    /// this closure should call `scanPhoto` in `PhotosSlidesVC+Find`
    var scanSlidesPhoto: ((SlidesPhoto) -> Void)?

    var photosToScan = [Photo]() {
        didSet {
            totalPhotosCount = photos.filter { !$0.isIgnored }.count
            scannedPhotosCount = totalPhotosCount - photosToScan.count
        }
    }

    /// is iCloud photos
    @Published var notes = [PhotosNote]()

    var scanningIconState: PhotosScanningIconState {
        if photosToScan.isEmpty {
            return .done
        }
        if scanningState == .dormant {
            return .paused
        }
        return .scanning
    }

    var scanningIconTapped: (() -> Void)? /// tapped icon in navigation bar
    var ignoredPhotosTapped: (() -> Void)?
    @Published var scanningState = ScanningState.dormant
    @Published var scannedPhotosCount = 0
    @Published var totalPhotosCount = 0 /// total where not ignored

    // MARK: Selection

    @Published var isSelecting = false
    @Published var selectedPhotos = [Photo]()
    var stopSelecting: (() -> Void)? /// call from within the SwiftUI toolbar

    // MARK: Ignored Photos

    var ignoredPhotos = [Photo]()

    /// focus a photo after tapping it in the ignored photos collection view
    var getSlidesViewControllerFor: ((Photo) -> PhotosSlidesItemViewController?)?

    // MARK: Share

    var sharePhotos: (([Photo]) -> Void)? /// multiple photos in main screen
    var sharePhotoInSlides: ((Photo) -> Void)? /// single photo

    // MARK: Deletion

    var deleteSelected: (() -> Void)?

    /// model updated, refresh collection views
    var reloadCollectionViewsAfterDeletion: (() -> Void)?

    /// don't update `slidesState` until this closure is called.
    var deletePhotoInSlides: ((Photo) -> Void)?
}

extension PhotosViewModel {
    enum ScanningState {
        case dormant
        case scanningAllPhotos
    }

    /// errors, warning, notes
    enum PhotosNote: Identifiable, Equatable {
        var id: String {
            switch self {
            case .downloadingFromCloud:
                return "downloadingFromCloud"
            case .photosFailedToScan(error: let error):
                return error
            }
        }

        static func == (lhs: PhotosNote, rhs: PhotosNote) -> Bool {
            lhs.id == rhs.id
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        case downloadingFromCloud
        case photosFailedToScan(error: String)

        func getTitle() -> String {
            switch self {
            case .downloadingFromCloud:
                return "Downloading photos from iCloud."
            case .photosFailedToScan:
                return "Failed to scan some photos."
            }
        }

        func getDescription() -> String {
            switch self {
            case .downloadingFromCloud:
                return "OpenFind fetches photos through Apple's built in APIs — all network connections are handled by Apple and not exposed to the app. Scanning may be slightly slower depending on your internet speed. "
            case .photosFailedToScan(error: let error):
                return "Error: [\(error)]. This could happen if you're using iCloud photos. To scan these photos, connect to the internet and download them to your device."
            }
        }

        func getIcon() -> String {
            switch self {
            case .downloadingFromCloud:
                return "icloud"
            case .photosFailedToScan:
                return "exclamationmark.icloud"
            }
        }
    }
}
