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
            Field(value: .string("1. Hello! This is some text.")),
            Field(value: .string("2. Hi.")),
            Field(value: .string("3. Medium text")),
            Field(value: .string("4. Longer long long long long long text")),
            Field(value: .string("5. Medium text")),
            Field(value: .string("6. Medium text")),
        ]
        
        setupCollectionViews()
        
        
    }
}

extension SearchViewController {
    func setupCollectionViews() {
        
        searchCollectionView.layer.borderColor = UIColor.purple.cgColor
        searchCollectionView.layer.borderWidth = 3
        searchCollectionView.delegate = self
        searchCollectionView.dataSource = self
        
        for index in fields.indices {
            fields[index].valueFrameWidth = calculateFrameWidth(text: fields[index].getText())
        }
        
        let flowLayout = SearchCollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.getCellWidth = { [weak self] in
//            return self?.widthOfExpandedCell() ?? 300
            return 300
        }
        flowLayout.getFields = { [weak self] in
            return self?.fields ?? [Field]()
        }
        searchCollectionView.setCollectionViewLayout(flowLayout, animated: false)
    }
}


