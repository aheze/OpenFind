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
    var months = [Month]()
    
    // MARK: Realm photo matching + loading
    let realm = try! Realm()
    var photoObjects: Results<HistoryModel>?
    
    let screenScale = UIScreen.main.scale
    
    // MARK: Diffable Data Source
    lazy var dataSource = makeDataSource()
    typealias DataSource = UICollectionViewDiffableDataSource<Month, FindPhoto>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Month, FindPhoto>
    let cellReuseIdentifier = "ImageCell"
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
        
        collectionView.register(UINib(nibName: "ImageCell", bundle: nil), forCellWithReuseIdentifier: cellReuseIdentifier)
        
        
//        collectionView.delegate = self
        collectionView.dataSource = dataSource
        configureLayout()
        
        let bottomInset = CGFloat(ConstantVars.tabHeight)
        collectionView.contentInset.bottom = 16 + segmentedSlider.bounds.height + bottomInset
        collectionView.verticalScrollIndicatorInsets.bottom = bottomInset
        segmentedSliderBottomC.constant = 8 + bottomInset
    }
}
