//
//  SearchViewController.swift
//  SearchBar
//
//  Created by Zheng on 10/14/21.
//

import UIKit

public class SearchViewController: UIViewController {
    
    var fields = [Field]()
    
    
    /// base view for everything
    @IBOutlet weak var baseView: UIView!
    
    /// blur background
    @IBOutlet weak var backgroundView: UIView!
    
    /// contains the search bar
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var searchCollectionView: UICollectionView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionViews()
        
        fields = [
            Field(
                value: .string("Hello! This is some text.")
            ),
            Field(
                value: .string("Hi.")
            ),
            Field(
                value: .string("Medium text")
            ),
        ]
    }
}

extension SearchViewController {
    func setupCollectionViews() {
        
        searchCollectionView.delegate = self
        searchCollectionView.dataSource = self
        
        let flowLayout = SearchCollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.getCellWidth = { [weak self] in
            let fullWidth = self?.view.safeAreaLayoutGuide.layoutFrame.width ?? 300
            return fullWidth - Constants.sidePadding
        }
        searchCollectionView.setCollectionViewLayout(flowLayout, animated: false)
    }
    func widthOfExpandedCell() -> Double {
        let fullWidth = view.safeAreaLayoutGuide.layoutFrame.width
        return fullWidth - Constants.sidePadding
    }
}


