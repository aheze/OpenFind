//
//  SettingsScrollViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

class SettingsScrollViewController: UIViewController, Searchable {
    var showSearchBar = false
    var baseSearchBarOffset = CGFloat(0)
    var additionalSearchBarOffset: CGFloat?

    let model: SettingsViewModel
    let searchViewModel: SearchViewModel
    let page: SettingsPage

    lazy var pageViewController: SettingsPageViewController = {
        let viewController = page.generateViewController()
        return viewController
    }()

    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.delegate = self
        scrollView.backgroundColor = .clear
        self.scrollView = scrollView
        return scrollView
    }()

    init(
        model: SettingsViewModel,
        searchViewModel: SearchViewModel,
        page: SettingsPage
    ) {
        self.model = model
        self.searchViewModel = searchViewModel
        self.page = page
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        title = page.title
        /**
         Instantiate the base `view`.
         */
        view = UIView()
        view.backgroundColor = .secondarySystemBackground

        _ = scrollView
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        baseSearchBarOffset = getCompactBarSafeAreaHeight(with: Global.safeAreaInsets)
        additionalSearchBarOffset = -scrollView.contentOffset.y - baseSearchBarOffset - searchViewModel.getTotalHeight()
    }
}

extension SettingsScrollViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = -scrollView.contentOffset.y
        additionalSearchBarOffset = contentOffset - baseSearchBarOffset - searchViewModel.getTotalHeight()
        model.updateNavigationBar?()
    }
}
