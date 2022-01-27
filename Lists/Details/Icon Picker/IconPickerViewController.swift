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
    var additionalSearchBarOffset = CGFloat(0)
    var updateSearchBarOffset: (() -> Void)?
    
    var model: IconPickerViewModel
    
    @IBOutlet var collectionView: UICollectionView!
    
    lazy var dataSource = makeDataSource()
    typealias DataSource = UICollectionViewDiffableDataSource<Category, String>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Category, String>
    
    init?(
        coder: NSCoder,
        model: IconPickerViewModel
    ) {
        self.model = model
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

        baseSearchBarOffset = getCompactBarSafeAreaHeight()
        collectionView.contentInset.top = IconPickerController.searchConfiguration.getTotalHeight()
        collectionView.verticalScrollIndicatorInsets.top = IconPickerController.searchConfiguration.getTotalHeight() + SearchNavigationConstants.scrollIndicatorTopPadding
        
        title = "Icons"
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem.menuButton(self, action: #selector(dismissSelf), imageName: "Dismiss")
        
        update(animate: false)
    }
    
    @objc func dismissSelf() {
        dismiss(animated: true)
    }
    
    func update(animate: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections(model.filteredCategories)
        model.filteredCategories.forEach { category in
            snapshot.appendItems(category.icons, toSection: category)
        }
        dataSource.apply(snapshot, animatingDifferences: animate)
    }
}

/// Scroll view
extension IconPickerViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = -scrollView.contentOffset.y
        additionalSearchBarOffset = contentOffset - baseSearchBarOffset - IconPickerController.searchConfiguration.getTotalHeight()
        updateSearchBarOffset?()
    }
}
