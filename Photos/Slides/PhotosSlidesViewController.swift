//
//  PhotosSlidesViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

class PhotosSlidesViewController: UIViewController, Searchable, InteractivelyDismissible, NavigationNamed {
    // MARK: - Searchable

    var baseSearchBarOffset = CGFloat(0)
    var additionalSearchBarOffset: CGFloat? /// nil to always have blur
    var updateSearchBarOffset: (() -> Void)?
    
    // MARK: - InteractivelyDismissible

    var isInteractivelyDismissing: Bool = false
    
    // MARK: NavigationNamed

    var name: NavigationName? = .listsDetail
    
    var model: PhotosViewModel
    var tabViewModel: TabViewModel
    var searchNavigationModel: SearchNavigationModel
    var searchNavigationProgressViewModel: ProgressViewModel
    var searchViewModel: SearchViewModel
    var slidesSearchViewModel: SearchViewModel
    var slidesSearchPromptViewModel: SearchPromptViewModel
    var toolbarViewModel: ToolbarViewModel
    lazy var toolbarView = PhotosSlidesToolbarView(model: model)
    
    /// includes collection view and info view
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet var collectionViewContainer: UIView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewContainerHeightC: NSLayoutConstraint!

    @IBOutlet weak var infoViewContainer: UIView!
    @IBOutlet weak var intoViewContainerHeightC: NSLayoutConstraint!
    
    
    lazy var flowLayout = PhotosSlidesCollectionLayout(model: model)
    lazy var dataSource: DataSource? = makeDataSource()
    typealias DataSource = UICollectionViewDiffableDataSource<DataSourceSectionTemplate, FindPhoto>
    typealias Snapshot = NSDiffableDataSourceSnapshot<DataSourceSectionTemplate, FindPhoto>

    // MARK: - Dismissal

    let tapPanGesture = UITapGestureRecognizer()
    let dismissPanGesture = UIPanGestureRecognizer()
    weak var transitionAnimator: PhotosTransitionDismissAnimator? /// auto set via the transition animator
    
    init?(
        coder: NSCoder,
        model: PhotosViewModel,
        tabViewModel: TabViewModel,
        searchNavigationModel: SearchNavigationModel,
        searchNavigationProgressViewModel: ProgressViewModel,
        searchViewModel: SearchViewModel,
        slidesSearchViewModel: SearchViewModel,
        slidesSearchPromptViewModel: SearchPromptViewModel,
        toolbarViewModel: ToolbarViewModel
    ) {
        self.model = model
        self.tabViewModel = tabViewModel
        self.searchNavigationModel = searchNavigationModel
        self.searchNavigationProgressViewModel = searchNavigationProgressViewModel
        self.searchViewModel = searchViewModel
        self.slidesSearchViewModel = slidesSearchViewModel
        self.slidesSearchPromptViewModel = slidesSearchPromptViewModel
        self.toolbarViewModel = toolbarViewModel
        super.init(coder: coder)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("You must create this view controller with metadata.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Photo"
        navigationItem.largeTitleDisplayMode = .never
        
        setup()
        listen()
        setupDismissGesture()
        setupTapGesture()
        update(animate: false)
        
        if
            let slidesState = model.slidesState,
            let currentIndex = slidesState.getCurrentIndex(),
            let findPhoto = slidesState.findPhotos[safe: currentIndex]
        {
            configureToolbar(for: findPhoto.photo)
            collectionView.layoutIfNeeded()
            collectionView.scrollToItem(at: currentIndex.indexPath, at: .centeredHorizontally, animated: true)
            model.updateAllowed = true
            if findPhoto.highlightsSet?.highlights.count ?? 0 > 0 {
                slidesSearchPromptViewModel.update(show: true, resultsText: findPhoto.getResultsText(), resetText: nil)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        withAnimation {
            toolbarViewModel.toolbar = AnyView(toolbarView)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabViewModel.excludedFrames[.photosSlidesItemCollectionView] = collectionView.windowFrame()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        tabViewModel.excludedFrames[.photosSlidesItemCollectionView] = nil
        switchToFullScreen(false)
        slidesSearchPromptViewModel.update(show: false)
        model.updateAllowed = true
        
        withAnimation {
            toolbarViewModel.toolbar = nil
        }
    }
    
    func boundsChanged(to size: CGSize, safeAreaInsets: UIEdgeInsets) {
        baseSearchBarOffset = getCompactBarSafeAreaHeight(with: safeAreaInsets)
        updateSearchBarOffset?()
    }
}
