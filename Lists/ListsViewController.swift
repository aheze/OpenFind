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
    
    let searchConfiguration = SearchConfiguration.lists
    var searchViewModel = SearchViewModel()
    lazy var searchViewController = createSearchBar()
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var searchContainerViewTopC: NSLayoutConstraint!
    
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
    
    
    var blur progress: CGFloat
    var navigationBarBackgroundBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    lazy var navigationBarBackground = createNavigationBarBackground()
    
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
        
        _ = searchViewController
        _ = listsFlowLayout
        _ = navigationBarBackground
        
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
