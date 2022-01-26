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
        searchConfiguration: SearchConfiguration
    ) {
        self.listsViewModel = listsViewModel
        self.searchConfiguration = searchConfiguration
        self.toolbarViewModel = toolbarViewModel
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
        listsViewModel.displayedLists = listsViewModel.lists.map { .init(list: $0) }
        
        view.backgroundColor = .secondarySystemBackground
        collectionView.backgroundColor = .clear
        
        setupCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        baseSearchBarOffset = getCompactBarSafeAreaHeight()
        additionalSearchBarOffset = -collectionView.contentOffset.y - baseSearchBarOffset - searchConfiguration.getTotalHeight()
    }
}
