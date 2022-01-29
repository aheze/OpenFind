//
//  ListsViewController.swift
//  Lists
//
//  Created by Zheng on 11/18/21.
//

import UIKit

class ListsViewController: UIViewController, Searchable {
    /// external models
    var listsViewModel: ListsViewModel
    var toolbarViewModel: ToolbarViewModel
    var realmModel: RealmModel
    var searchConfiguration: SearchConfiguration
    
    var baseSearchBarOffset = CGFloat(0)
    var additionalSearchBarOffset = CGFloat(0)
    
    var updateNavigationBar: (() -> Void)?
    
    @IBOutlet var collectionView: UICollectionView!
    lazy var listsFlowLayout: ListsCollectionFlowLayout = createFlowLayout()
    
    /// details
    var detailsViewController: ListsDetailViewController?
    
    init?(
        coder: NSCoder,
        listsViewModel: ListsViewModel,
        toolbarViewModel: ToolbarViewModel,
        realmModel: RealmModel,
        searchConfiguration: SearchConfiguration
    ) {
        self.listsViewModel = listsViewModel
        self.toolbarViewModel = toolbarViewModel
        self.realmModel = realmModel
        self.searchConfiguration = searchConfiguration
        super.init(coder: coder)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("You must create this view controller with metadata.")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Lists"
        
        _ = listsFlowLayout
        listsViewModel.displayedLists = realmModel.lists.map { .init(list: $0) }
        
        view.backgroundColor = .secondarySystemBackground
        collectionView.backgroundColor = .clear
        
        setupCollectionView()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        baseSearchBarOffset = getCompactBarSafeAreaHeight()
        additionalSearchBarOffset = -collectionView.contentOffset.y - baseSearchBarOffset - searchConfiguration.getTotalHeight()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        /// refresh for dark mode
        updateCellColors()
    }
    
//    var safeAreaInset = UIEdgeInsets.zero
//    
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//        coordinator.animate { context in
//            let insets = self.collectionView.safeAreaInsets
//            self.safeAreaInset = insets
//            let availableWidth = size.width
//                - ListsCollectionConstants.sidePadding * 2
//                - insets.left
//                - insets.right
//            
//            print("Width::: \(availableWidth).. \(self.collectionView.safeAreaInsets)")
//            for index in self.listsViewModel.displayedLists.indices {
//                let oldDisplayedList = self.listsViewModel.displayedLists[index]
//                _ = self.getCellSize(availableWidth: availableWidth, list: oldDisplayedList.list, listIndex: index)
//                let newDisplayedList = self.listsViewModel.displayedLists[index]
//                
//                if let cell = self.collectionView.cellForItem(at: index.indexPath) as? ListsContentCell {
//                    self.addChipViews(to: cell, with: newDisplayedList)
//                }
//            }
//        }
//    }
}
