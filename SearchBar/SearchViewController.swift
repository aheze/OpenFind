//
//  SearchViewController.swift
//  SearchBar
//
//  Created by Zheng on 10/14/21.
//

import UIKit

class SearchViewController: UIViewController {
    var searchViewModel: SearchViewModel
    var configuration: SearchConfiguration
    
    @IBOutlet var searchBarHeightC: NSLayoutConstraint!
    @IBOutlet weak var searchBarTopC: NSLayoutConstraint!
    @IBOutlet weak var searchBarBottomC: NSLayoutConstraint!
    
    lazy var searchCollectionViewFlowLayout: SearchCollectionViewFlowLayout = {
        return createFlowLayout()
    }()
    
    /// base view for everything
    @IBOutlet var baseView: UIView!
    
    /// blur background
    @IBOutlet var backgroundView: UIView!
    
    /// contains the search bar
    @IBOutlet var searchBarView: UIView!
    @IBOutlet var searchCollectionView: SearchCollectionView!
    
    init?(
        coder: NSCoder,
        searchViewModel: SearchViewModel,
        configuration: SearchConfiguration
    ) {
        self.searchViewModel = searchViewModel
        self.configuration = configuration
        
        /// inject the configuration for cell width calculations
        for index in searchViewModel.fields.indices {
            searchViewModel.fields[index].configuration = configuration
        }
        
        super.init(coder: coder)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("You must create this view controller with metadata.")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
        searchBarHeightC.constant = configuration.cellHeight
        searchBarTopC.constant = configuration.backgroundTopPadding
        searchBarBottomC.constant = configuration.backgroundBottomPadding
        searchBarView.backgroundColor = .clear
        backgroundView.isHidden = !configuration.showBackground
        setupCollectionViews()
        searchCollectionView.contentInsetAdjustmentBehavior = .never

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
            if searchCollectionViewFlowLayout.highlightingAddWordField {
                convertAddNewCellToRegularCell { [weak self] in
                    self?.addNewCellToRight()
                }
            }
        default:
            break
        }
    }
}
