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
    let realmModel: RealmModel
    let searchViewModel: SearchViewModel
    let page: SettingsPage

    lazy var pageViewController: SettingsPageViewController = {
        let viewController = page.generateViewController(model: model, realmModel: realmModel)
        return viewController
    }()

    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.pinEdgesToSuperview()
        scrollView.delegate = self
        scrollView.backgroundColor = .clear
        scrollView.alwaysBounceVertical = true
        scrollView.verticalScrollIndicatorInsets.top = SearchNavigationConstants.scrollIndicatorTopPadding
        self.scrollView = scrollView
        return scrollView
    }()

    lazy var contentView: UIView = {
        let contentView = UIView()
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            contentView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        return contentView
    }()

    init(
        model: SettingsViewModel,
        realmModel: RealmModel,
        searchViewModel: SearchViewModel,
        page: SettingsPage
    ) {
        self.model = model
        self.realmModel = realmModel
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
        navigationItem.largeTitleDisplayMode = .never
        /**
         Instantiate the base `view`.
         */
        view = UIView()
        view.backgroundColor = .secondarySystemBackground

        _ = scrollView
        _ = contentView
        addResizableChildViewController(pageViewController, in: contentView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        baseSearchBarOffset = getCompactBarSafeAreaHeight(with: .zero)
        additionalSearchBarOffset = 0
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { _ in
            self.baseSearchBarOffset = self.getCompactBarSafeAreaHeight(with: .zero)
            self.updateSearchBarOffsetFromScroll(scrollView: self.scrollView)
        }
    }
}

extension SettingsScrollViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateSearchBarOffsetFromScroll(scrollView: scrollView)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        model.touchesEnabled = false
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        model.touchesEnabled = true
    }

    func updateSearchBarOffsetFromScroll(scrollView: UIScrollView) {
        let contentOffset = -scrollView.contentOffset.y
        additionalSearchBarOffset = contentOffset - baseSearchBarOffset
        model.updateNavigationBar?()
    }
}
