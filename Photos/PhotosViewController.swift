//
//  PhotosViewController.swift
//  Photos
//
//  Created by Zheng on 11/18/21.
//

import SwiftUI

class PhotosViewController: UIViewController, PageViewController, Searchable {
    var tabType: TabState = .photos
    
    var model: PhotosViewModel
    var toolbarViewModel: ToolbarViewModel
    var realmModel: RealmModel
    var searchViewModel: SearchViewModel
    var slidesSearchViewModel: SearchViewModel
    var permissionsViewModel = PhotosPermissionsViewModel()
    
    var baseSearchBarOffset = CGFloat(0)
    var additionalSearchBarOffset: CGFloat? = CGFloat(0)
    var updateNavigationBar: (() -> Void)?
    
    var photosSelectionViewModel = PhotosSelectionViewModel()
    lazy var selectionToolbar = PhotosSelectionToolbarView(model: photosSelectionViewModel)
    lazy var scanningIconController = PhotosScanningIconController(model: model)
    lazy var scanningNavigationViewController = UINavigationController(
        rootViewController: PhotosScanningViewController(model: model)
    )
    
    @IBOutlet var collectionView: UICollectionView!
    lazy var flowLayout = PhotosCollectionFlowLayout(model: model)
    lazy var dataSource = makeDataSource()
    typealias DataSource = UICollectionViewDiffableDataSource<PhotosSection, Photo>
    typealias Snapshot = NSDiffableDataSourceSnapshot<PhotosSection, Photo>
    
    @IBOutlet var resultsCollectionView: UICollectionView!
    lazy var resultsFlowLayout = PhotosCollectionFlowLayout(model: model)
    lazy var resultsDataSource = makeResultsDataSource()
    typealias ResultsDataSource = UICollectionViewDiffableDataSource<PhotoSlidesSection, FindPhoto>
    typealias ResultsSnapshot = NSDiffableDataSourceSnapshot<PhotoSlidesSection, FindPhoto>
    
    init?(
        coder: NSCoder,
        model: PhotosViewModel,
        toolbarViewModel: ToolbarViewModel,
        realmModel: RealmModel,
        searchViewModel: SearchViewModel,
        slidesSearchViewModel: SearchViewModel
    ) {
        self.model = model
        self.toolbarViewModel = toolbarViewModel
        self.realmModel = realmModel
        self.searchViewModel = searchViewModel
        self.slidesSearchViewModel = slidesSearchViewModel
        super.init(coder: coder)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("You must create this view controller with metadata.")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Photos"
        setup()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        baseSearchBarOffset = getCompactBarSafeAreaHeight(with: Global.safeAreaInsets)
        additionalSearchBarOffset = -collectionView.contentOffset.y - baseSearchBarOffset - searchViewModel.getTotalHeight()
        updateNavigationBar?()
    }
}
