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

    var showSearchBar = true
    var baseSearchBarOffset = CGFloat(0)
    var additionalSearchBarOffset: CGFloat? /// nil to always have blur
    var updateSearchBarOffset: (() -> Void)?

    // MARK: - InteractivelyDismissible

    var isInteractivelyDismissing: Bool = false

    // MARK: NavigationNamed

    var name: NavigationName? = .listsDetail

    /// navigation title
    var navigationTitleStackView: UIStackView!
    var titleLabel: UILabel!
    var subtitleLabel: UILabel!

    var model: PhotosViewModel
    var tabViewModel: TabViewModel
    var searchNavigationModel: SearchNavigationModel
    var searchNavigationProgressViewModel: ProgressViewModel
    var searchViewModel: SearchViewModel
    var slidesSearchViewModel: SearchViewModel
    var slidesSearchPromptViewModel: SearchPromptViewModel
    var toolbarViewModel: ToolbarViewModel
    var realmModel: RealmModel
    lazy var toolbarView = PhotosSlidesToolbarView(model: model)

    /// includes collection view and info view
    @IBOutlet var scrollView: ManualScrollView!
    @IBOutlet var contentView: UIView!

    @IBOutlet var collectionViewToolbarContainer: UIView!
    @IBOutlet var collectionViewToolbarHeightC: NSLayoutConstraint!
    @IBOutlet var collectionViewContainer: UIView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionViewContainerHeightC: NSLayoutConstraint!

    // MARK: Info

    @IBOutlet var infoViewContainer: UIView!
    @IBOutlet var infoViewContainerHeightC: NSLayoutConstraint!
    lazy var infoNoteHighlightViewModel = HighlightsViewModel()
    lazy var infoNoteTextViewModel = EditableTextViewModel(configuration: .infoSlides)

    lazy var flowLayout = makeFlowLayout()
    lazy var dataSource: DataSource? = makeDataSource()
    typealias DataSource = UICollectionViewDiffableDataSource<DataSourceSectionTemplate, SlidesPhoto>
    typealias Snapshot = NSDiffableDataSourceSnapshot<DataSourceSectionTemplate, SlidesPhoto>

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
        toolbarViewModel: ToolbarViewModel,
        realmModel: RealmModel
    ) {
        self.model = model
        self.tabViewModel = tabViewModel
        self.searchNavigationModel = searchNavigationModel
        self.searchNavigationProgressViewModel = searchNavigationProgressViewModel
        self.searchViewModel = searchViewModel
        self.slidesSearchViewModel = slidesSearchViewModel
        self.slidesSearchPromptViewModel = slidesSearchPromptViewModel
        self.toolbarViewModel = toolbarViewModel
        self.realmModel = realmModel
        super.init(coder: coder)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("You must create this view controller with metadata.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        accessibilityViewIsModal = true

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
            if let highlights = slidesPhoto.findPhoto.highlightsSet?.highlights, highlights.count > 3 {
                realmModel.incrementExperience(by: 6)
            }

            model.configureToolbar(for: slidesPhoto.findPhoto.photo)
            collectionView.layoutIfNeeded()
            collectionView.scrollToItem(at: currentIndex.indexPath, at: .centeredHorizontally, animated: true)
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

        tabViewModel.excludedFrames[.photosSlidesItemCollectionView] = view.bounds
    }

    override func viewWillDisappear(_ animated: Bool) {
        resetInfoToHidden(scrollIfNeeded: true)
        searchViewModel.dismissKeyboard?()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        tabViewModel.excludedFrames[.photosSlidesItemCollectionView] = nil
        switchToFullScreen(false)
        slidesSearchPromptViewModel.update(show: false)

        withAnimation {
            toolbarViewModel.toolbar = nil
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        resetInfoToHidden(scrollIfNeeded: true)
        collectionViewContainerHeightC.constant = size.height

        coordinator.animate { _ in
            self.scrollView.layoutIfNeeded()
        }
    }

    func boundsChanged(to size: CGSize, safeAreaInsets: UIEdgeInsets) {
        baseSearchBarOffset = getCompactBarSafeAreaHeight(with: safeAreaInsets)
        updateSearchBarOffset?()
    }

    /// get associated view controller
    func getViewController(for photo: Photo) -> PhotosSlidesItemViewController? {
        guard let index = model.slidesState?.getSlidesPhotoIndex(photo: photo) else { return nil }
        guard let cell = collectionView.cellForItem(at: index.indexPath) as? PhotosSlidesContentCell else { return nil }
        guard let viewController = cell.viewController else { return nil }

        return viewController
    }
}
