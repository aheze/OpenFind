//
//  IgnoredPhotosViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/14/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

class IgnoredPhotosViewController: UIViewController {
    /// external models
    var model: PhotosViewModel
    
    var headerContentModel = HeaderContentModel()
    var ignoredPhotosHeaderViewModel = IgnoredPhotosHeaderViewModel()
    lazy var headerView = IgnoredPhotosHeaderView(model: model, ignoredPhotosHeaderViewModel: ignoredPhotosHeaderViewModel)
    
    typealias DataSource = UICollectionViewDiffableDataSource<DataSourceSectionTemplate, Photo>
    typealias Snapshot = NSDiffableDataSourceSnapshot<DataSourceSectionTemplate, Photo>
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    lazy var dataSource = makeDataSource()
    lazy var flowLayout = makeFlowLayout()
    
    init(model: PhotosViewModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        title = "Ignored Photos"
        navigationItem.largeTitleDisplayMode = .never
        
        /**
         Instantiate the base `view`.
         */
        view = UIView()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        update()
    }
    
    @objc func dismissSelf() {
        dismiss(animated: true)
    }
}
