//
//  ListsViewController.swift
//  Lists
//
//  Created by Zheng on 11/18/21.
//

import UIKit

class ListsViewController: UIViewController, PageViewController {
    var tabType: TabState = .lists
    
    /// external models
    var listsViewModel: ListsViewModel
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    lazy var listsFlowLayout: ListsCollectionFlowLayout = {
        let flowLayout = ListsCollectionFlowLayout()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Lists"
        
        _ = listsFlowLayout
        listsViewModel.displayedLists = listsViewModel.lists
        setupCollectionView()
        
    }
}

extension ListsViewController {
    func willBecomeActive() {}
    
    func didBecomeActive() {}
    
    func willBecomeInactive() {}
    
    func didBecomeInactive() {}
}
