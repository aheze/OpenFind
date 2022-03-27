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
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    
    @IBOutlet var collectionViewContainer: UIView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionViewContainerHeightC: NSLayoutConstraint!

    @IBOutlet var infoViewContainer: UIView!
    @IBOutlet var infoViewContainerHeightC: NSLayoutConstraint!
    
    lazy var flowLayout = makeFlowLayout()
    lazy var dataSource: DataSource? = makeDataSource()
    typealias DataSource = UICollectionViewDiffableDataSource<DataSourceSectionTemplate, SlidesPhoto>
    typealias Snapshot = NSDiffableDataSourceSnapshot<DataSourceSectionTemplate, SlidesPhoto>
    
    // MARK: - Deletion
    var photoToDelete: Photo?
    var targetIndexAfterDeletion: Int?

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
            let slidesPhoto = slidesState.slidesPhotos[safe: currentIndex]
        {
            configureToolbar(for: slidesPhoto.findPhoto.photo)
            collectionView.layoutIfNeeded()
            collectionView.scrollToItem(at: currentIndex.indexPath, at: .centeredHorizontally, animated: true)
            model.updateAllowed = true
            if slidesPhoto.findPhoto.highlightsSet?.highlights.count ?? 0 > 0 {
                slidesSearchPromptViewModel.update(show: true, resultsText: slidesPhoto.findPhoto.getResultsText(), resetText: nil)
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
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        resetInfoToHidden()
    }
    func boundsChanged(to size: CGSize, safeAreaInsets: UIEdgeInsets) {
        baseSearchBarOffset = getCompactBarSafeAreaHeight(with: safeAreaInsets)
        updateSearchBarOffset?()
    }
}
