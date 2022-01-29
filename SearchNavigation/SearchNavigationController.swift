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
    
    var onWillBecomeActive: (() -> Void)?
    var onDidBecomeActive: (() -> Void)?
    var onWillBecomeInactive: (() -> Void)?
    var onDidBecomeInactive: (() -> Void)?
    var onBoundsChange: ((CGSize, UIEdgeInsets) -> Void)?
    
    var rootViewController: UIViewController
    var searchViewModel: SearchViewModel
    var navigation: UINavigationController!
    
    var searchContainerViewContainer = PassthroughView() /// whole screen
    var searchContainerView: UIView!
    var searchContainerViewTopC: NSLayoutConstraint?
    var searchViewController: SearchViewController!
    
    var navigationBarBackgroundContainer = PassthroughView()
    var navigationBarBackgroundHeightC: NSLayoutConstraint!
    var navigationBarBackground = UIView()
    var navigationBarBackgroundBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
    var navigationBarBackgroundBorderView = UIView()
    var animator: UIViewPropertyAnimator?
    var blurPercentage = CGFloat(0)
    
    /// testing
    var testing = false
    
    static func make(
        rootViewController: Searchable,
        searchViewModel: SearchViewModel,
        tabType: TabState
    ) -> SearchNavigationController {
        
        let storyboard = UIStoryboard(name: "SearchNavigationContent", bundle: nil)
        let searchNavigationController = storyboard.instantiateViewController(identifier: "SearchNavigationController") { coder in
            SearchNavigationController(
                coder: coder,
                rootViewController: rootViewController,
                searchViewModel: searchViewModel,
                tabType: tabType
            )
        }
        return searchNavigationController
    }
    
    init?(
        coder: NSCoder,
        rootViewController: UIViewController,
        searchViewModel: SearchViewModel,
        tabType: TabState
    ) {
        self.rootViewController = rootViewController
        self.searchViewModel = searchViewModel
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
        navigation.delegate = self
        
        addChildViewController(navigation, in: view)
        setupNavigationBar()
        setupSearchBar()
        
        /// refresh the blur after coming back from app switcher
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self.setupBlur()
            self.animator?.fractionComplete = self.blurPercentage
        }
    }
    
    deinit {
        animator?.stopAnimation(true)
    }
}



