//
//  IconPickerViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/25/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

class IconPickerViewController: UIViewController, Searchable {
    /// searchable
    var baseSearchBarOffset = CGFloat(0)
    var additionalSearchBarOffset: CGFloat? = CGFloat(0)
    var updateSearchBarOffset: (() -> Void)?
    
    var model: IconPickerViewModel
    var searchViewModel: SearchViewModel
    
    @IBOutlet var collectionView: UICollectionView!
    
    lazy var dataSource = makeDataSource()
    typealias DataSource = UICollectionViewDiffableDataSource<Category, String>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Category, String>
    
    init?(
        coder: NSCoder,
        model: IconPickerViewModel,
        searchViewModel: SearchViewModel
    ) {
        self.model = model
        self.searchViewModel = searchViewModel
        super.init(coder: coder)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.contentInset.top = searchViewModel.getTotalHeight()
        collectionView.verticalScrollIndicatorInsets.top = searchViewModel.getTotalHeight() + SearchNavigationConstants.scrollIndicatorTopPadding
        
        title = "Icons"
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem.menuButton(self, action: #selector(dismissSelf), imageName: "Dismiss")
        
        let jumpButton = UIBarButtonItem(
            image: UIImage(systemName: "arrow.forward.to.line"),
            style: .plain,
            target: self,
            action: #selector(jumpToIcon)
        )
        navigationItem.leftBarButtonItem = jumpButton
        
        update(animate: false)
    }
    
    @objc func dismissSelf() {
        dismiss(animated: true)
    }
    
    @objc func jumpToIcon() {
        if let indexPath = dataSource.indexPath(for: model.selectedIcon) {
            collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
        }
    }
    
    func update(animate: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections(model.filteredCategories)
        model.filteredCategories.forEach { category in
            snapshot.appendItems(category.icons, toSection: category)
        }
        dataSource.apply(snapshot, animatingDifferences: animate)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        baseSearchBarOffset = getCompactBarSafeAreaHeight(with: .zero)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { _ in
            self.baseSearchBarOffset = self.getCompactBarSafeAreaHeight(with: .zero)
        }
    }
}

/// Scroll view
extension IconPickerViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = -scrollView.contentOffset.y
        additionalSearchBarOffset = contentOffset - baseSearchBarOffset - searchViewModel.getTotalHeight()
        updateSearchBarOffset?()
    }
}
