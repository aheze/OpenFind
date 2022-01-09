//
//  SearchNavigationController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/9/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//


import UIKit

class SearchNavigationController: UIViewController {
    let searchConfiguration = SearchConfiguration.lists
    var searchViewModel = SearchViewModel()
    lazy var searchViewController = createSearchBar()
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var searchContainerViewTopC: NSLayoutConstraint!
    
    lazy var navigationBarBackground = createNavigationBarBackground()
    var navigationBarBackgroundBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    var navigationBarBackgroundBorderView = UIView()
    var animator: UIViewPropertyAnimator?
    
    var scrollView = UIScrollView()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = navigationBarBackground
        _ = searchViewController
        scrollView.verticalScrollIndicatorInsets.top = searchConfiguration.getTotalHeight() + 4 /// prevent blur on the indicator
    }
    
    deinit {
        animator?.stopAnimation(true)
    }
}


