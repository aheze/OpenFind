//
//  SearchNavigationController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/9/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//


import UIKit

protocol SearchNavigationUpdater: UIViewController {
    func updateSearchBarOffset(offset: CGFloat)
}
class SearchNavigationController: UIViewController {
    
    var navigation: UINavigationController!
    var rootViewController: UIViewController
    let searchConfiguration: SearchConfiguration
    
    var searchViewModel = SearchViewModel()
    var searchViewController: SearchViewController!
    var searchContainerView: UIView!
    var searchContainerViewTopC: NSLayoutConstraint!
    
    var navigationBarBackground = UIView()
    var navigationBarBackgroundBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
    var navigationBarBackgroundBorderView = UIView()
    var animator: UIViewPropertyAnimator?
    var blurPercentage = CGFloat(0)

    
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
        addChildViewController(navigation, in: view)
        setupSearchBar()
        setupNavigationBar()
        _ = navigationBarBackground
        _ = searchViewController
        
        print("load.")
        
        navigation.interactivePopGestureRecognizer?.addTarget(self, action: #selector(popGestureHandler))
        
//        scrollView.verticalScrollIndicatorInsets.top = searchConfiguration.getTotalHeight() + 4 /// prevent blur on the indicator
    
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



extension SearchNavigationController: SearchNavigationUpdater {
    func updateSearchBarOffset(offset: CGFloat) {
        print("up: \(offset)")
        searchContainerViewTopC.constant = offset
        updateBlur(offset: offset)
    }
}
