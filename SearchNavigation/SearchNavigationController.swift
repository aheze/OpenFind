//
//  SearchNavigationController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/9/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//


import UIKit

class SearchNavigationController: UIViewController {
    
    var navigation: UINavigationController!
    var rootViewController: UIViewController
    let searchConfiguration: SearchConfiguration
    
    var searchContainerViewContainer = PassthroughView() /// whole screen
    var searchContainerView: UIView!
    var searchContainerViewTopC: NSLayoutConstraint!
    var searchViewModel = SearchViewModel()
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
    
    var currentViewControllerCount = 0
    
    static func make(rootViewController: Searchable, searchConfiguration: SearchConfiguration) -> SearchNavigationController {
        
        let storyboard = UIStoryboard(name: "SearchNavigationContent", bundle: nil)
        let searchNavigationController = storyboard.instantiateViewController(identifier: "SearchNavigationController") { coder in
            SearchNavigationController(
                coder: coder,
                rootViewController: rootViewController,
                searchConfiguration: searchConfiguration
            )
        }
        return searchNavigationController
    }
    
    init?(
        coder: NSCoder,
        rootViewController: UIViewController,
        searchConfiguration: SearchConfiguration
    ) {
        self.rootViewController = rootViewController
        self.searchConfiguration = searchConfiguration
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
        setupSearchBar()
        setupNavigationBar()
        
        _ = navigationBarBackground
        _ = searchViewController
        
        self.currentViewControllerCount = navigation.viewControllers.count
        
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



