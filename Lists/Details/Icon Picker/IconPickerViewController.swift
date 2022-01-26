//
//  IconPickerViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/25/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

class IconPickerController {
    var searchNavigationController: SearchNavigationController
    var iconPickerViewController: IconPickerViewController
    static let searchConfiguration = SearchConfiguration.photos
    
    init(model: IconPickerViewModel) {
        let storyboard = UIStoryboard(name: "ListsContent", bundle: nil)
        let iconPickerViewController = storyboard.instantiateViewController(identifier: "IconPickerViewController") { coder in
            IconPickerViewController(coder: coder, model: model)
        }
        let searchNavigationController = SearchNavigationController.make(
            rootViewController: iconPickerViewController,
            searchConfiguration: IconPickerController.searchConfiguration,
            tabType: .lists
        )
        
        self.searchNavigationController = searchNavigationController
        self.iconPickerViewController = iconPickerViewController
        
        iconPickerViewController.updateSearchBarOffset = { [weak self] in
            guard let self = self else { return }
            self.searchNavigationController.updateSearchBarOffset()
        }
        
        searchNavigationController.searchViewModel.fieldsChanged = { [weak self] (oldValue, newValue) in
            guard let self = self else { return }
            
            let oldText = oldValue.map { $0.value.getText() }
            let newText = newValue.map { $0.value.getText() }
            let textIsSame = oldText == newText
            
            if !textIsSame {
                print("Searches: \(newText)")
                self.iconPickerViewController.model.filter(words: newText.filter { !$0.isEmpty })
                self.iconPickerViewController.collectionView.reloadData()
            }
            
            
            
            
        }
    }
}

class IconPickerViewController: UIViewController, Searchable {
    var baseSearchBarOffset = CGFloat(0)
    var additionalSearchBarOffset = CGFloat(0)

    var model = IconPickerViewModel()
    @IBOutlet var collectionView: UICollectionView!
    
    var updateSearchBarOffset: (() -> Void)?
    
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
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        baseSearchBarOffset = getCompactBarSafeAreaHeight()
        collectionView.contentInset.top = IconPickerController.searchConfiguration.getTotalHeight()
        collectionView.verticalScrollIndicatorInsets.top = IconPickerController.searchConfiguration.getTotalHeight() + SearchNavigationConstants.scrollIndicatorTopPadding
        
        title = "Icons"
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem.menuButton(self, action: #selector(dismissSelf), imageName: "Dismiss")
    }
    
    @objc func dismissSelf() {
        dismiss(animated: true)
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
