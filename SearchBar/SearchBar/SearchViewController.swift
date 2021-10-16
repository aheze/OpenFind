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
        
        setupCollectionViews()
        
        
    }
}

extension SearchViewController {
    func setupCollectionViews() {
        
        searchCollectionView.delegate = self
        searchCollectionView.dataSource = self
        
        for index in fields.indices {
            fields[index].valueFrameWidth = calculateFrameWidth(text: fields[index].getText())
        }
        
        let flowLayout = SearchCollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.getCellWidth = { [weak self] in
            return self?.widthOfExpandedCell() ?? 300
        }
        flowLayout.getFields = { [weak self] in
            return self?.fields ?? [Field]()
        }
        searchCollectionView.setCollectionViewLayout(flowLayout, animated: false)
    }
}


