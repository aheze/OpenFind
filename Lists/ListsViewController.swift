//
//  ListsViewController.swift
//  Lists
//
//  Created by Zheng on 11/18/21.
//

import UIKit

class ListsViewController: UIViewController, Searchable, PageViewController {
    
    var tabType: TabState = .lists
    
    /// external models
    var listsViewModel: ListsViewModel
    var searchConfiguration: SearchConfiguration
    var searchBarOffset = CGFloat(0)
    var updateNavigationBar: (() -> Void)?
    
    @IBOutlet weak var collectionView: UICollectionView!
    lazy var listsFlowLayout: ListsCollectionFlowLayout = createFlowLayout()
    
    
    init?(
        coder: NSCoder,
        listsViewModel: ListsViewModel,
        searchConfiguration: SearchConfiguration
    ) {
        self.listsViewModel = listsViewModel
        self.searchConfiguration = searchConfiguration
        super.init(coder: coder)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("You must create this view controller with metadata.")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Lists"
        
        _ = listsFlowLayout
        
        listsViewModel.displayedLists = listsViewModel.lists.map { .init(list: $0) }
        
        setupCollectionView()
        
        view.backgroundColor = .secondarySystemBackground
        collectionView.backgroundColor = .clear
    }
}

extension ListsViewController {
    func willBecomeActive() {}
    
    func didBecomeActive() {}
    
    func willBecomeInactive() {}
    
    func didBecomeInactive() {}
}
