//
//  PhotosViewController.swift
//  Photos
//
//  Created by Zheng on 11/18/21.
//

import SwiftUI

class PhotosViewController: UIViewController, PageViewController, Searchable {
    var tabType: TabState = .photos
    
    /// external models
    var model: PhotosViewModel
    var realmModel: RealmModel
    var tabViewModel: TabViewModel
    var photosPermissionsViewModel: PhotosPermissionsViewModel
    var toolbarViewModel: ToolbarViewModel
    var searchNavigationModel: SearchNavigationModel
    var searchViewModel: SearchViewModel
    var searchNavigationProgressViewModel: ProgressViewModel
    var slidesSearchViewModel: SearchViewModel
    var slidesSearchPromptViewModel: SearchPromptViewModel
    
    /// internal models
    
    var sliderViewModel = SliderViewModel()
    var resultsHeaderViewModel = ResultsHeaderViewModel()
    var progressViewModel = ProgressViewModel(foregroundColor: Colors.accent, backgroundColor: .clear)
    lazy var headerContentModel = HeaderContentModel()
    lazy var resultsHeaderView = ResultsHeaderView(
        model: model,
        resultsHeaderViewModel: resultsHeaderViewModel,
        progressViewModel: progressViewModel
    )
    var resultsHeaderHeightC: NSLayoutConstraint?
    
    /// Searchable
    var showSearchBar = true
    var baseSearchBarOffset = CGFloat(0)
    var additionalSearchBarOffset: CGFloat? = CGFloat(0)
    var updateNavigationBar: (() -> Void)?
    
    /// selection
    var selectBarButton: UIBarButtonItem?
    var scanningBarButton: UIBarButtonItem?
    lazy var selectionToolbar = PhotosSelectionToolbarView(model: model)
    lazy var scanningIconController = PhotosScanningIconController(model: model)
    lazy var scanningNavigationViewController = UINavigationController(
        rootViewController: PhotosScanningViewController(model: model, realmModel: realmModel)
    )
    
    // MARK: Collection View

    @IBOutlet var collectionViewContainer: UIView!
    @IBOutlet var collectionView: UICollectionView!
    lazy var flowLayout = makeFlowLayout()
    lazy var dataSource = makeDataSource()
    typealias DataSource = UICollectionViewDiffableDataSource<PhotosSection, Photo>
    typealias Snapshot = NSDiffableDataSourceSnapshot<PhotosSection, Photo>
    
    @IBOutlet var resultsCollectionView: UICollectionView!
    lazy var resultsFlowLayout = makeResultsFlowLayout()
    lazy var resultsDataSource = makeResultsDataSource()
    typealias ResultsDataSource = UICollectionViewDiffableDataSource<DataSourceSectionTemplate, FindPhoto>
    typealias ResultsSnapshot = NSDiffableDataSourceSnapshot<DataSourceSectionTemplate, FindPhoto>
    
    /// for SwiftUI views
    @IBOutlet weak var contentContainer: UIView!
    
    
    // MARK: Filtering

    @IBOutlet var sliderContainerView: UIView!
    @IBOutlet var sliderContainerViewHeightC: NSLayoutConstraint!
    @IBOutlet var sliderContainerViewBottomC: NSLayoutConstraint!
    
    
    var loadedPhotos = false
    init?(
        coder: NSCoder,
        model: PhotosViewModel,
        realmModel: RealmModel,
        tabViewModel: TabViewModel,
        photosPermissionsViewModel: PhotosPermissionsViewModel,
        toolbarViewModel: ToolbarViewModel,
        searchNavigationModel: SearchNavigationModel,
        searchViewModel: SearchViewModel,
        searchNavigationProgressViewModel: ProgressViewModel,
        slidesSearchViewModel: SearchViewModel,
        slidesSearchPromptViewModel: SearchPromptViewModel
    ) {
        self.model = model
        self.realmModel = realmModel
        self.tabViewModel = tabViewModel
        self.photosPermissionsViewModel = photosPermissionsViewModel
        self.toolbarViewModel = toolbarViewModel
        self.searchNavigationModel = searchNavigationModel
        self.searchViewModel = searchViewModel
        self.searchNavigationProgressViewModel = searchNavigationProgressViewModel
        self.slidesSearchViewModel = slidesSearchViewModel
        self.slidesSearchPromptViewModel = slidesSearchPromptViewModel
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
        
        /// set the top padding for the empty content view
        model.emptyContentTopPadding = searchViewModel.getTotalHeight()
        
        if model.resultsState != nil {
            updateNavigationBlur(with: resultsCollectionView)
        } else {
            updateNavigationBlur(with: collectionView)
        }
    }
}
