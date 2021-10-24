//
//  SearchViewController.swift
//  SearchBar
//
//  Created by Zheng on 10/14/21.
//

import UIKit

public class SearchViewController: UIViewController {
    
    var fields = [Field]()
    
    lazy var searchCollectionViewFlowLayout: SearchCollectionViewFlowLayout = {
        let flowLayout = SearchCollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.getFullCellWidth = { [weak self] index in
            return self?.widthOfExpandedCell(for: index) ?? 300
        }
        flowLayout.getFields = { [weak self] in
            return self?.fields ?? [Field]()
        }
        flowLayout.highlightAddNewField = { [weak self] shouldHighlight in
            self?.shouldHighlight(shouldHighlight)
        }
        searchCollectionView.setCollectionViewLayout(flowLayout, animated: false)
        return flowLayout
    }()
    
    
    
    /// base view for everything
    @IBOutlet weak var baseView: UIView!
    
    /// blur background
    @IBOutlet weak var backgroundView: UIView!
    
    /// contains the search bar
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var searchCollectionView: SearchCollectionView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        fields = [
            Field(value: .string("1. Hello! This is")),
            Field(value: .string("2. Hi.")),
            Field(value: .string("3.a Medium text")),
//            Field(value: .string("3.b Medium text")),
//            Field(value: .string("3.c Medium text")),
//            Field(value: .string("3.d Medium text")),
            Field(value: .string("4. Longer long long long long long text")),
            Field(value: .string("5. Text")),
            Field(value: .addNew)
        ]
        
        setupCollectionViews()
        
        
    }
}

extension SearchViewController {
    func setupCollectionViews() {
//        searchCollectionView.clipsToBounds = false
//        searchCollectionView.layer.borderWidth = 3
//        searchCollectionView.layer.borderColor = UIColor.purple.cgColor
        
        searchCollectionView.decelerationRate = .fast
        searchCollectionView.showsHorizontalScrollIndicator = false
        
        searchCollectionView.delegate = self
        searchCollectionView.dataSource = self
        searchCollectionView.delaysContentTouches = true /// allow scrolling through text fields
        
        for index in fields.indices {
            fields[index].fieldHuggingWidth = getFieldHuggingWidth(fieldText: fields[index].getText())
        }
        
        _ = searchCollectionViewFlowLayout
    }
}


