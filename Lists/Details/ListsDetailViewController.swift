//
//  ListsDetailViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//


import SwiftUI

class ListsDetailViewController: UIViewController, Searchable {
    
    var list: List
    var searchConfiguration: SearchConfiguration
    
    var baseSearchBarOffset = CGFloat(0)
    var additionalSearchBarOffset = CGFloat(0)
    var updateSearchBarOffset: (() -> Void)?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    init?(
        coder: NSCoder,
        list: List,
        searchConfiguration: SearchConfiguration
    ) {
        self.list = list
        self.searchConfiguration = searchConfiguration
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "List"
        navigationItem.largeTitleDisplayMode = .never
        
        baseSearchBarOffset = getCompactBarSafeAreaHeight()
//        additionalSearchBarOffset = -scrollView.contentOffset.y - baseSearchBarOffset - searchConfiguration.getTotalHeight()
        
        scrollView.contentInset.top = searchConfiguration.getTotalHeight()
        scrollView.verticalScrollIndicatorInsets.top = searchConfiguration.getTotalHeight() + SearchNavigationConstants.scrollIndicatorTopPadding
        
        scrollView.delegate = self
        
        scrollView.backgroundColor = .clear
        contentView.backgroundColor = .clear
        view.backgroundColor = .secondarySystemBackground
    }
}

/// Scroll view
extension ListsDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = -scrollView.contentOffset.y
        additionalSearchBarOffset = contentOffset - baseSearchBarOffset - searchConfiguration.getTotalHeight()
        updateSearchBarOffset?()
    }
}
