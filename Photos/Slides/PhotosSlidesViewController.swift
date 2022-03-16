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
    var slidesSearchViewModel: SearchViewModel
    var slidesSearchPromptViewModel: SearchPromptViewModel
    var toolbarViewModel: ToolbarViewModel
    lazy var toolbarView = PhotosSlidesToolbarView(model: model)
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var collectionView: UICollectionView!
    
    lazy var flowLayout = PhotosSlidesCollectionLayout(model: model)
    lazy var dataSource = makeDataSource()
    typealias DataSource = UICollectionViewDiffableDataSource<PhotoSlidesSection, FindPhoto>
    typealias Snapshot = NSDiffableDataSourceSnapshot<PhotoSlidesSection, FindPhoto>

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
        slidesSearchViewModel: SearchViewModel,
        slidesSearchPromptViewModel: SearchPromptViewModel,
        toolbarViewModel: ToolbarViewModel
    ) {
        self.model = model
        self.tabViewModel = tabViewModel
        self.searchNavigationModel = searchNavigationModel
        self.searchNavigationProgressViewModel = searchNavigationProgressViewModel
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
        
        if let (findPhoto, currentIndex) = model.slidesState?.getCurrentFindPhotoAndIndex() {
            configureToolbar(for: findPhoto.photo)
            collectionView.layoutIfNeeded()
            collectionView.scrollToItem(at: currentIndex.indexPath, at: .centeredHorizontally, animated: true)
            if findPhoto.highlights?.count ?? 0 > 0{
                slidesSearchPromptViewModel.show(true)
                slidesSearchPromptViewModel.resultsText = findPhoto.getResultsText()
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
        slidesSearchPromptViewModel.show(false)
        
        withAnimation {
            toolbarViewModel.toolbar = nil
        }
    }
    
    func boundsChanged(to size: CGSize, safeAreaInsets: UIEdgeInsets) {
        baseSearchBarOffset = getCompactBarSafeAreaHeight(with: safeAreaInsets)
        updateSearchBarOffset?()
    }
}
