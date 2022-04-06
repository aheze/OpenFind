//
//  SearchNavigationController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/9/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

class SearchNavigationController: UIViewController, PageViewController {
    var tabType: TabState
    var rootViewController: UIViewController
    
    var model: SearchNavigationModel
    var searchViewModel: SearchViewModel
    var detailsSearchViewModel: SearchViewModel?
    var detailsSearchPromptViewModel: SearchPromptViewModel?
    var realmModel: RealmModel /// for the search bar
    var navigation: UINavigationController!
    
    var navigationBarBackgroundContainer = PassthroughView()
    var navigationBarBackgroundHeightC: NSLayoutConstraint!
    var navigationBarBackground = UIView()
    var navigationBarBackgroundBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
    var navigationBarBackgroundBorderView = UIView()
    var animator: UIViewPropertyAnimator?
    var blurPercentage = CGFloat(0)

    var searchContainerViewContainer = PassthroughView() /// whole screen
    var searchContainerViewContainerTopC: NSLayoutConstraint? /// whole screen top constraint
    var searchContainerView: UIView! /// hugs the search bar
    var searchContainerViewTopC: NSLayoutConstraint? /// top of the container view, animate this to adjust y offset of search bar
    var searchContainerViewLeftC: NSLayoutConstraint? /// left of the container view, adjust to negative value when presenting detail view controllers without search bar
    var searchViewController: SearchViewController!
    var detailsSearchViewController: SearchViewController?
    
    /// goes inside `searchContainerViewContainer`
    var detailsSearchPromptViewContainer = UIView()
    var detailsSearchPromptViewContainerTopC: NSLayoutConstraint!
    var detailsSearchPromptViewContainerHeightC: NSLayoutConstraint!
    
    var progressViewModel: ProgressViewModel?
    var progressContainerView = UIView()

    // MARK: - Optional Transitioning

    var pushAnimator: UIViewControllerAnimatedTransitioning?
    var popAnimator: UIViewControllerAnimatedTransitioning?
    var dismissAnimator: UIViewControllerAnimatedTransitioning?
    
    /// the current transitioning animator
    var currentAnimator: UIViewControllerAnimatedTransitioning?
    
    static func make(
        rootViewController: Searchable,
        searchNavigationModel: SearchNavigationModel,
        searchViewModel: SearchViewModel,
        realmModel: RealmModel,
        tabType: TabState
    ) -> SearchNavigationController {
        let storyboard = UIStoryboard(name: "SearchNavigationContent", bundle: nil)
        let searchNavigationController = storyboard.instantiateViewController(identifier: "SearchNavigationController") { coder in
            SearchNavigationController(
                coder: coder,
                rootViewController: rootViewController,
                searchNavigationModel: searchNavigationModel,
                searchViewModel: searchViewModel,
                realmModel: realmModel,
                tabType: tabType
            )
        }
        return searchNavigationController
    }
    
    init?(
        coder: NSCoder,
        rootViewController: UIViewController,
        searchNavigationModel: SearchNavigationModel,
        searchViewModel: SearchViewModel,
        realmModel: RealmModel,
        tabType: TabState
    ) {
        self.rootViewController = rootViewController
        self.model = searchNavigationModel
        self.searchViewModel = searchViewModel
        self.realmModel = realmModel
        self.tabType = tabType
        super.init(coder: coder)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("You must create this view controller with metadata.")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigation = UINavigationController(rootViewController: rootViewController)
        navigation.interactivePopGestureRecognizer?.delegate = nil /// re-enable the swipe back gesture, even when `animationControllerFor` is implemented
        navigation.delegate = self
        
        addChildViewController(navigation, in: view)
        setupNavigationBar()
        setupSearchBar()
        setupPrompt()
        setupProgress()
        listen()
        
        /// refresh the blur after coming back from app switcher
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self.setupBlur()
            self.animator?.fractionComplete = self.blurPercentage
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { context in
            let insets = self.view.safeAreaInsets
            self.model.onBoundsChange?(size, insets)
        }
    }
    
    deinit {
        animator?.stopAnimation(true)
    }
}
