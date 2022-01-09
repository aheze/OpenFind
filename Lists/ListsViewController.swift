//
//  ListsViewController.swift
//  Lists
//
//  Created by Zheng on 11/18/21.
//

import UIKit

class ListsViewController: SearchNavigationController, PageViewController {
    var tabType: TabState = .lists
    
    /// external models
    var listsViewModel: ListsViewModel
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    lazy var listsFlowLayout: ListsCollectionFlowLayout = {
        let topPadding = searchConfiguration.getTotalHeight()
        let flowLayout = ListsCollectionFlowLayout(topPadding: topPadding)
        flowLayout.scrollDirection = .horizontal
        flowLayout.getLists = { [weak self] in
            guard let self = self else { return [] }
            return self.listsViewModel.displayedLists
        }

        collectionView.setCollectionViewLayout(flowLayout, animated: false)
        return flowLayout
    }()
    
    
    init?(
        coder: NSCoder,
        listsViewModel: ListsViewModel
    ) {
        self.listsViewModel = listsViewModel
        super.init(coder: coder)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("You must create this view controller with metadata.")
    }
    
    override var scrollView: UIScrollView {
        get {
            collectionView
        }
        set {
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = listsFlowLayout
        
        listsViewModel.displayedLists = listsViewModel.lists
        
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
