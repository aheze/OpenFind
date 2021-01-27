//
//  PhotosViewController.swift
//  Find
//
//  Created by Zheng on 1/1/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import Photos
import RealmSwift

class PhotosViewController: UIViewController {
    var migrationNeeded = false
    var photosToMigrate = [HistoryModel]()
    var folderURL = URL(fileURLWithPath: "", isDirectory: true)
    
    @IBOutlet weak var segmentedSlider: SegmentedSlider!
    @IBOutlet weak var segmentedSliderBottomC: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: Photo loading
    var hasPermissions = false
    var hasFullAccess = false
    var allPhotos: PHFetchResult<PHAsset>? = nil
    var allMonths = [Month]() /// all photos
    var monthsToDisplay = [Month]() /// shown photos, including filters
    var allPhotosToDisplay = [FindPhoto]() /// shown photos, including filters, but without grouping by month
    var currentFilter = PhotoFilter.all
    var activityIndicator: UIActivityIndicatorView? /// show photo loading
    
    // MARK: Realm photo matching + loading
    let realm = try! Realm()
    var photoObjects: Results<HistoryModel>?
    let screenScale = UIScreen.main.scale /// for photo thumbnail
    var refreshNeededAtLoad = false /// refresh when view did appear
    var refreshNeededAfterDismissPhoto = false /// refresh as soon as dismiss photo slides
    var refreshing = false /// currently refreshing data, prevent select cell
    
    var emptyDescriptionView: EmptyDescriptionView?
    
    // MARK: Photo selection
    var showSelectionControls: ((Bool) -> Void)? /// show or hide
    var updateActions: ((ChangeActions) -> Void)? /// switch star/unstar and cache/uncache
    
    /// Whether is in select mode or not
    var selectButtonSelected = false
    var indexPathsSelected = [IndexPath]()
    var numberOfSelected = 0 {
        didSet {
            determineActions()
            updateSelectionLabel(to: numberOfSelected)
            
            if numberOfSelected == 0 {
                dimSlideControls?(true, true)
            } else {
                dimSlideControls?(false, true)
            }
        }
    }
    
    var shouldStarSelection = false /// if press **star** button, should apply star or remove
    var shouldCacheSelection = false /// if press **cache** button, should apply cache or remove
    
    var selectedIndexPath: IndexPath? /// current indexPath pressed when go to slides vc
    var currentlyPresentingSlides = false /// whether currently presenting the slides or not
    var changePresentationMode: ((Bool) -> Void)? /// notify the parent to change the tab bar
    var currentSlidesController: PhotoSlidesViewController? /// currently presenting
    var photoSlideControlPressed: ((PhotoSlideAction) -> Void)? /// pressed action in tab bar
    var dimSlideControls: ((Bool, Bool) -> Void)? /// dim the controls during dismissal, is photos  = true / for dismissal = false
    
    // MARK: Slides
    var updateSlideActions: ((ChangeActions) -> Void)? /// switch star/unstar and cache/uncache
    var findPhotoChanged: (() -> Void)? /// starred/cached photos
    var hideTabBar: ((Bool) -> Void)?

    
    // MARK: Diffable Data Source
    lazy var dataSource = makeDataSource()
    typealias DataSource = UICollectionViewDiffableDataSource<Month, FindPhoto>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Month, FindPhoto>
    let cellReuseIdentifier = "ImageCell"
    let headerReuseIdentifier = "PhotoHeader"
    var slidesPresentingInfo: ((Bool) -> Void)?
   
    // MARK: Nav bar
    var findButton: UIBarButtonItem!
    var selectButton: UIBarButtonItem!
    
    // MARK: Finding
    var hasChangedFromBefore = false /// whether photo deleted, cached, or something changed
    var switchToFind: ((PhotoFilter, [FindPhoto], Bool, Bool) -> Void)? /// filter, photos to find from, is all photos, has changed from before
    var switchBack: (() -> Void)?
    @IBOutlet weak var shadeView: UIView!
    
    @IBOutlet weak var collapseButton: UIButton! /// dismiss Finding
    @IBAction func collapseButtonPressed(_ sender: Any) {
        switchBack?()
        if selectButtonSelected {
            showSelectionControls?(true)
        }
    }
    
    let defaults = UserDefaults.standard
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        segmentedSlider.indicatorView.frame = segmentedSlider.getIndicatorViewFrame(for: segmentedSlider.currentFilter, withInset: true).1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = UIColor(named: "PhotosText")
        
        
        checkTutorial()
        
        setupBarButtons()
        getRealmObjects()

        collectionView.register(UINib(nibName: "ImageCell", bundle: nil), forCellWithReuseIdentifier: cellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = dataSource
        
        if migrationNeeded {
            showMigrationView(photosToMigrate: photosToMigrate, folderURL: folderURL)
        } else {
            addActivityIndicator()
            fadeCollectionView(true, instantly: true)
            fetchAssets()
        }
        
        setupSDWebImage()
        configureLayout()
        setupFinding()

        let bottomInset = CGFloat(ConstantVars.tabHeight)
        let bottomSafeAreaHeight = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.bottom ?? 0
        collectionView.contentInset.bottom = 16 + segmentedSlider.bounds.height + bottomInset
        collectionView.verticalScrollIndicatorInsets.bottom = bottomInset - CGFloat(bottomSafeAreaHeight)
        segmentedSliderBottomC.constant = 8 + bottomInset

        getSliderCallback()
        
        if hasPermissions {
            startObservingChanges()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        if refreshNeededAtLoad {
            refreshNeededAtLoad = false
            refreshing = true
            DispatchQueue.main.async {
                self.loadImages { (allPhotos, allMonths) in
                    self.allMonths = allMonths
                    self.monthsToDisplay = allMonths
                    self.allPhotosToDisplay = allPhotos
                    self.sortPhotos(with: self.currentFilter)
                    self.applySnapshot(animatingDifferences: true)
                    self.refreshing = false
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSlides" {
            if let navigationController = self.navigationController, let viewController = segue.destination as? PhotoSlidesViewController {
                configureSlides(navigationController: navigationController, slidesViewController: viewController)
            }
        }
    }
}
