//
//  SearchViewController.swift
//  SearchBar
//
//  Created by Zheng on 10/14/21.
//

import UIKit

class SearchViewController: UIViewController {
    var searchViewModel: SearchViewModel
    @IBOutlet var searchBarHeightC: NSLayoutConstraint!
    
    lazy var searchCollectionViewFlowLayout: SearchCollectionViewFlowLayout = {
        let flowLayout = SearchCollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.getFullCellWidth = { [weak self] index in
            self?.widthOfExpandedCell(for: index) ?? 300
        }
        flowLayout.getFields = { [weak self] in
            self?.searchViewModel.fields ?? [Field]()
        }
        flowLayout.highlightAddNewField = { [weak self] shouldHighlight in
            self?.highlight(shouldHighlight)
        }
        flowLayout.focusedCellIndexChanged = { [weak self] oldCellIndex, newCellIndex in
            guard let self = self else { return }
            if let oldCellIndex = oldCellIndex {
                self.searchViewModel.fields[oldCellIndex].focused = false /// for cellForItemAt later, after cell reloads
                if let cell = self.searchCollectionView.cellForItem(at: oldCellIndex.indexPath) as? SearchFieldCell {
//                    cell.field = self.searchViewModel.fields[oldCellIndex] /// set it right now anyway
                    cell.triggerButton.isEnabled = true
                }
            }
            if let newCellIndex = newCellIndex, self.searchViewModel.fields.indices.contains(newCellIndex) {
                self.searchViewModel.fields[newCellIndex].focused = true
                if let cell = self.searchCollectionView.cellForItem(at: newCellIndex.indexPath) as? SearchFieldCell {
//                    cell.field = self.searchViewModel.fields[newCellIndex] /// set it right now anyway
                    cell.textField.becomeFirstResponder()
                    cell.triggerButton.isEnabled = false
                }
            }
        }
        
        flowLayout.convertAddNewToRegularCellInstantly = { [weak self] completion in
            
            /// make it blue first
            self?.highlight(true, generateHaptics: true, animate: false)
            self?.convertAddNewCellToRegularCell { [weak self] in
                self?.addNewCellToRight()
                completion()
            }
        }
        
        searchCollectionView.setCollectionViewLayout(flowLayout, animated: false)
        return flowLayout
    }()
    
    /// base view for everything
    @IBOutlet var baseView: UIView!
    
    /// blur background
    @IBOutlet var backgroundView: UIView!
    
    /// contains the search bar
    @IBOutlet var searchBarView: UIView!
    @IBOutlet var searchCollectionView: SearchCollectionView!
    
    init?(coder: NSCoder, searchViewModel: SearchViewModel) {
        self.searchViewModel = searchViewModel
        super.init(coder: coder)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("You must create this view controller with metadata.")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        searchBarHeightC.constant = SearchConstants.cellHeight

        searchBarView.backgroundColor = .clear
        setupCollectionViews()
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
