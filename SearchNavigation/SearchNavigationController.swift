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
    
    var scrollView = UIScrollView()
    
//    init?(
//        coder: NSCoder,
//        scrollView: UIScrollView
//    ) {
//        self.scrollView = scrollView
//        super.init(coder: coder)
//    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("You must create this view controller with metadata.")
    }
}

extension SearchNavigationController {
    func createSearchBar() -> SearchViewController {
        let searchViewController = Bridge.makeViewController(
            searchViewModel: searchViewModel,
            configuration: searchConfiguration
        )
        
        searchContainerView.backgroundColor = .clear
        addResizableChildViewController(searchViewController, in: searchContainerView)
        searchContainerViewTopC.constant = scrollView.adjustedContentInset.top /// top safe area by default
        
        return searchViewController
    }
}
