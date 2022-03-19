//
//  ListsViewController.swift
//  Lists
//
//  Created by Zheng on 11/18/21.
//

import UIKit

class ListsViewController: UIViewController, Searchable {
    var model: ListsViewModel
    
    /// external models
    var tabViewModel: TabViewModel
    var toolbarViewModel: ToolbarViewModel
    var realmModel: RealmModel
    var searchViewModel: SearchViewModel
    var detailsSearchViewModel: SearchViewModel
    
    var baseSearchBarOffset = CGFloat(0)
    var additionalSearchBarOffset: CGFloat? = CGFloat(0)
    
    var updateNavigationBar: (() -> Void)?
    
    @IBOutlet var collectionView: UICollectionView!
    lazy var listsFlowLayout: ListsCollectionFlowLayout = createFlowLayout()
    
    /// details
    var detailsViewController: ListsDetailViewController?
    
    /// selection
    var selectBarButton: UIBarButtonItem!
    lazy var toolbarView = ListsSelectionToolbarView(model: model)
    
    init?(
        coder: NSCoder,
        model: ListsViewModel,
        tabViewModel: TabViewModel,
        toolbarViewModel: ToolbarViewModel,
        realmModel: RealmModel,
        searchViewModel: SearchViewModel,
        detailsSearchViewModel: SearchViewModel
    ) {
        self.model = model
        self.tabViewModel = tabViewModel
        self.toolbarViewModel = toolbarViewModel
        self.realmModel = realmModel
        self.searchViewModel = searchViewModel
        self.detailsSearchViewModel = detailsSearchViewModel
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
        
        view.backgroundColor = .secondarySystemBackground
        collectionView.backgroundColor = .clear
        
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        baseSearchBarOffset = getCompactBarSafeAreaHeight(with: Global.safeAreaInsets)
        additionalSearchBarOffset = -collectionView.contentOffset.y - baseSearchBarOffset - searchViewModel.getTotalHeight()
        updateNavigationBar?()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        /// refresh for dark mode
        updateCellColors()
    }
}
