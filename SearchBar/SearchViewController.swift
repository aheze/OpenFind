//
//  SearchViewController.swift
//  SearchBar
//
//  Created by Zheng on 10/14/21.
//

import Combine
import UIKit

class SearchViewController: UIViewController {
    var searchViewModel: SearchViewModel
    var realmModel: RealmModel
    var collectionViewModel = SearchCollectionViewModel()
    
    @IBOutlet var searchBarHeightC: NSLayoutConstraint!
    @IBOutlet var searchBarTopC: NSLayoutConstraint!
    @IBOutlet var searchBarBottomC: NSLayoutConstraint!
    
    lazy var searchCollectionViewFlowLayout: SearchCollectionViewFlowLayout = createFlowLayout()
    
    /// base view for everything
    @IBOutlet var baseView: UIView!
    
    /// blur background
    @IBOutlet var backgroundView: UIView!
    
    /// contains the search bar
    @IBOutlet var searchBarView: UIView!
    @IBOutlet var searchCollectionView: SearchCollectionView!
    
    lazy var keyboardToolbarViewModel = KeyboardToolbarViewModel()
    lazy var toolbarViewController = KeyboardToolbarViewController(
        searchViewModel: searchViewModel,
        realmModel: realmModel,
        model: keyboardToolbarViewModel,
        collectionViewModel: collectionViewModel
    )
    
    static func make(searchViewModel: SearchViewModel, realmModel: RealmModel) -> SearchViewController {
        let bundle = Bundle(identifier: "com.aheze.SearchBar")
        let storyboard = UIStoryboard(name: "SearchBar", bundle: bundle)
        let viewController = storyboard.instantiateViewController(identifier: "SearchViewController") { coder in
            SearchViewController(
                coder: coder,
                searchViewModel: searchViewModel,
                realmModel: realmModel
            )
        }
    
        return viewController
    }
    
    init?(
        coder: NSCoder,
        searchViewModel: SearchViewModel,
        realmModel: RealmModel
    ) {
        self.searchViewModel = searchViewModel
        self.realmModel = realmModel
        
        /// inject the configuration for cell width calculations
        for index in searchViewModel.fields.indices {
            var field = self.searchViewModel.fields[index]
            field.configuration = searchViewModel.configuration
            self.searchViewModel.updateField(at: index, with: field, notify: false)
        }
        
        super.init(coder: coder)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("You must create this view controller with metadata.")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false /// allow auto sizing
        
        updateLandscapeConstants()
        searchBarTopC.constant = 0
        searchBarBottomC.constant = 0
        searchBarView.backgroundColor = .clear
        backgroundView.isHidden = !searchViewModel.configuration.showBackground
        setupCollectionViews()
        searchCollectionView.contentInsetAdjustmentBehavior = .never
        
        listen()
        
        realmModel.$lists
            .dropFirst()
            .sink { [weak self] lists in
                guard let self = self else { return }
                self.listsChanged(newLists: lists)
            }
            .store(in: &realmModel.cancellables)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateLandscapeConstants()
    }

    func updateLandscapeConstants() {
        if traitCollection.horizontalSizeClass == .regular {
            searchViewModel.isLandscape = true
        } else {
            searchViewModel.isLandscape = false
        }
        searchBarHeightC.constant = searchViewModel.getTotalHeight()
    }
}

extension SearchViewController {
    func setupCollectionViews() {
        /// actually important, when there's only 1 search bar
        searchCollectionView.alwaysBounceHorizontal = true
        searchCollectionView.decelerationRate = .fast
        searchCollectionView.showsHorizontalScrollIndicator = false
        
        searchCollectionView.delegate = self
        searchCollectionView.dataSource = self
        searchCollectionView.allowsSelection = false
        searchCollectionView.contentInsetAdjustmentBehavior = .never
        
        let bundle = Bundle(identifier: "com.aheze.SearchBar")
        let nib = UINib(nibName: "SearchFieldCell", bundle: bundle)
        searchCollectionView.register(nib, forCellWithReuseIdentifier: "Cell")
        _ = searchCollectionViewFlowLayout /// initialize and set up
        
        searchCollectionView.panGestureRecognizer.addTarget(self, action: #selector(handlePan(_:)))
    }
    
    /// convert "Add New" cell into a normal field
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .ended:
            if collectionViewModel.highlightingAddWordField {
                convertAddNewCellToRegularCell { [weak self] in
                    self?.addNewCellToRight()
                }
            }
        default:
            break
        }
    }
}
