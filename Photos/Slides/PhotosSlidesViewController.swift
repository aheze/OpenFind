//
//  PhotosSlidesViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

class PhotoSlidesSection: Hashable {
    let id = 0
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: PhotoSlidesSection, rhs: PhotoSlidesSection) -> Bool {
        lhs.id == rhs.id
    }
}

class PhotosSlidesViewController: UIViewController, Searchable, InteractivelyDismissible {
    // MARK: - Searchable

    var baseSearchBarOffset = CGFloat(0)
    var additionalSearchBarOffset: CGFloat? /// nil to always have blur
    var updateSearchBarOffset: (() -> Void)?
    
    // MARK: - InteractivelyDismissible

    var isInteractivelyDismissing: Bool = false
    
    var model: PhotosViewModel
    var tabViewModel: TabViewModel
    var searchNavigationModel: SearchNavigationModel
    var slidesSearchViewModel: SearchViewModel
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
        slidesSearchViewModel: SearchViewModel,
        toolbarViewModel: ToolbarViewModel
    ) {
        self.model = model
        self.tabViewModel = tabViewModel
        self.searchNavigationModel = searchNavigationModel
        self.slidesSearchViewModel = slidesSearchViewModel
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
        
        if let slidesState = model.slidesState, let index = slidesState.currentIndex {
            collectionView.layoutIfNeeded()
            collectionView.scrollToItem(at: index.indexPath, at: .centeredHorizontally, animated: true)
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
        
        withAnimation {
            toolbarViewModel.toolbar = nil
        }
    }
    
    func boundsChanged(to size: CGSize, safeAreaInsets: UIEdgeInsets) {
        baseSearchBarOffset = getCompactBarSafeAreaHeight(with: safeAreaInsets)
        updateSearchBarOffset?()
    }
}
