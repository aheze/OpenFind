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

class PhotosNavController: UINavigationController {
    var viewController: PhotosViewController!
}
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
    
    // MARK: Realm photo matching + loading
    let realm = try! Realm()
    var photoObjects: Results<HistoryModel>?
    let screenScale = UIScreen.main.scale /// for photo thumbnail
    
    // MARK: Photo selection
    var updateSelectionLabel: ((Int) -> Void)?
    
    /// Whether is in select mode or not
    var selectButtonSelected = false
    var indexPathsSelected = [IndexPath]()
    var numberOfSelected = 0 {
        didSet {
            updateSelectionLabel?(numberOfSelected)
        }
    }
    
    var selectedIndexPath: IndexPath? /// current indexPath pressed when go to slides vc
    var currentlyPresentingSlides = false /// whether currently presenting the slides or not
    var changePresentationMode: ((Bool) -> Void)? /// notify the parent to change the tab bar
    var currentSlidesController: PhotoSlidesViewController? /// currently presenting
    var photoSlideControlPressed: ((PhotoSlideAction) -> Void)? /// pressed action in tab bar
    
    // MARK: Diffable Data Source
    lazy var dataSource = makeDataSource()
    typealias DataSource = UICollectionViewDiffableDataSource<Month, FindPhoto>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Month, FindPhoto>
    let cellReuseIdentifier = "ImageCell"
    let headerReuseIdentifier = "PhotoHeader"
   
    // MARK: Nav bar
    var findButton: UIBarButtonItem!
    var selectButton: UIBarButtonItem!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        segmentedSlider.indicatorView.frame = segmentedSlider.getIndicatorViewFrame(for: segmentedSlider.currentFilter, withInset: true).1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        
        setUpBarButtons()
        getRealmObjects()
        
        if migrationNeeded {
            showMigrationView(photosToMigrate: photosToMigrate, folderURL: folderURL)
        } else {
            fetchAssets()
        }
        
        setUpSDWebImage()
        collectionView.register(UINib(nibName: "ImageCell", bundle: nil), forCellWithReuseIdentifier: cellReuseIdentifier)
        
        collectionView.delegate = self
        collectionView.dataSource = dataSource
        configureLayout()
        
        let bottomInset = CGFloat(ConstantVars.tabHeight)
        collectionView.contentInset.bottom = 16 + segmentedSlider.bounds.height + bottomInset
        collectionView.verticalScrollIndicatorInsets.bottom = bottomInset
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
