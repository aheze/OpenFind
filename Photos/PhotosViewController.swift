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
    var tabViewModel: TabViewModel
    var toolbarViewModel: ToolbarViewModel
    var searchNavigationModel: SearchNavigationModel
    var searchViewModel: SearchViewModel
    var searchNavigationProgressViewModel: ProgressViewModel
    var slidesSearchViewModel: SearchViewModel
    var slidesSearchPromptViewModel: SearchPromptViewModel
    
    /// internal models
    var permissionsViewModel = PhotosPermissionsViewModel()
    var resultsHeaderViewModel = ResultsHeaderViewModel()
    var headerContentModel = HeaderContentModel()
    var sliderViewModel = SliderViewModel()
    lazy var resultsHeaderContainer = UIView()
    lazy var resultsHeaderView = ResultsHeaderView(model: model, resultsHeaderViewModel: resultsHeaderViewModel)
    var resultsHeaderHeightC: NSLayoutConstraint!
    
    var baseSearchBarOffset = CGFloat(0)
    var additionalSearchBarOffset: CGFloat? = CGFloat(0)
    var updateNavigationBar: (() -> Void)?
    
    /// selection
    var selectBarButton: UIBarButtonItem!
    var scanningBarButton: UIBarButtonItem!
    lazy var selectionToolbar = PhotosSelectionToolbarView(model: model)
    lazy var scanningIconController = PhotosScanningIconController(model: model)
    lazy var scanningNavigationViewController = UINavigationController(
        rootViewController: PhotosScanningViewController(model: model)
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
    
    init?(
        coder: NSCoder,
        model: PhotosViewModel,
        tabViewModel: TabViewModel,
        toolbarViewModel: ToolbarViewModel,
        searchNavigationModel: SearchNavigationModel,
        searchViewModel: SearchViewModel,
        searchNavigationProgressViewModel: ProgressViewModel,
        slidesSearchViewModel: SearchViewModel,
        slidesSearchPromptViewModel: SearchPromptViewModel
    ) {
        self.model = model
        self.tabViewModel = tabViewModel
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
        if model.resultsState != nil {
            updateNavigationBlur(with: resultsCollectionView)
        } else {
            updateNavigationBlur(with: collectionView)
        }
    }
}
