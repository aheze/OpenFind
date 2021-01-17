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
        }
    }
    
    var shouldStarSelection = false /// if press **star** button, should apply star or remove
    var shouldCacheSelection = false /// if press **cache** button, should apply cache or remove
    
    var selectedIndexPath: IndexPath? /// current indexPath pressed when go to slides vc
    var currentlyPresentingSlides = false /// whether currently presenting the slides or not
    var changePresentationMode: ((Bool) -> Void)? /// notify the parent to change the tab bar
    var currentSlidesController: PhotoSlidesViewController? /// currently presenting
    var photoSlideControlPressed: ((PhotoSlideAction) -> Void)? /// pressed action in tab bar
    var dimSlideControls: ((Bool) -> Void)? /// dim the controls during dismissal
    
    // MARK: Diffable Data Source
    lazy var dataSource = makeDataSource()
    typealias DataSource = UICollectionViewDiffableDataSource<Month, FindPhoto>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Month, FindPhoto>
    let cellReuseIdentifier = "ImageCell"
    let headerReuseIdentifier = "PhotoHeader"
   
    // MARK: Nav bar
    var findButton: UIBarButtonItem!
    var selectButton: UIBarButtonItem!
    
    // MARK: Finding
    var switchToFind: ((PhotoFilter, [FindPhoto]) -> Void)?
    
    @IBOutlet weak var collapseButton: UIButton! /// dismiss Finding
    @IBAction func collapseButtonPressed(_ sender: Any) {
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        segmentedSlider.indicatorView.frame = segmentedSlider.getIndicatorViewFrame(for: segmentedSlider.currentFilter, withInset: true).1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        
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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSlides" {
            if let navigationController = self.navigationController, let viewController = segue.destination as? PhotoSlidesViewController {
                configureSlides(navigationController: navigationController, slidesViewController: viewController)
            }
        }
    }
}
