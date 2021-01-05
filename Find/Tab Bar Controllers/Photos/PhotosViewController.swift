//
//  PhotosViewController.swift
//  Find
//
//  Created by Zheng on 1/1/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import Photos

class PhotosNavController: UINavigationController {
    var viewController: PhotosViewController!
}
class PhotosViewController: UIViewController {
    var migrationNeeded = false
    var photosToMigrate = [HistoryModel]()
    var folderURL = URL(fileURLWithPath: "", isDirectory: true)
    
    @IBOutlet weak var segmentedSlider: SegmentedSlider!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: Photo loading
    var hasFullAccess = false
    var allPhotos: PHFetchResult<PHAsset>? = nil
    var months = [Month]()
    
    // MARK: Diffable Data Source
    lazy var dataSource = makeDataSource()
    typealias DataSource = UICollectionViewDiffableDataSource<Month, PHAsset>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Month, PHAsset>
    let cellReuseIdentifier = "PhotoCell"
    let headerReuseIdentifier = "PhotoHeader"
   
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        segmentedSlider.indicatorView.frame = segmentedSlider.getIndicatorViewFrame(for: segmentedSlider.currentFilter, withInset: true).1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        if migrationNeeded {
            showMigrationView(photosToMigrate: photosToMigrate, folderURL: folderURL)
        } else {
            fetchAssets()
        }
        
        setUpSDWebImage()
        
//        collectionView.delegate = self
        collectionView.dataSource = dataSource
        configureLayout()
    }
}
