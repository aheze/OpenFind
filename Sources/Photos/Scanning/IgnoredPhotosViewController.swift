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
    var realmModel: RealmModel
    var ignoredPhotosViewModel = IgnoredPhotosViewModel()
    
    typealias DataSource = UICollectionViewDiffableDataSource<DataSourceSectionTemplate, Photo>
    typealias Snapshot = NSDiffableDataSourceSnapshot<DataSourceSectionTemplate, Photo>
    lazy var collectionContainer = UIView()
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    lazy var dataSource = makeDataSource()
    lazy var flowLayout = makeFlowLayout()
    
    var selectBarButton: UIBarButtonItem!
    lazy var toolbarContainer = UIView()
    lazy var toolbarView = IgnoredPhotosToolbarView(model: model, ignoredPhotosViewModel: ignoredPhotosViewModel)
    
    lazy var headerContentModel = HeaderContentModel()
    lazy var ignoredPhotosHeaderView = IgnoredPhotosHeaderView(model: model)
    var ignoredPhotosHeaderHeightC: NSLayoutConstraint?
    
    init(
        model: PhotosViewModel,
        realmModel: RealmModel
    ) {
        self.model = model
        self.realmModel = realmModel
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
        view.backgroundColor = .systemBackground
        
        setup()
        listen()
        ignoredPhotosViewModel.ignoredPhotosChanged = { [weak self] in
            guard let self = self else { return }
            
            self.updateViewsEnabled()
            self.update(animate: true)
            self.ignoredPhotosViewModel.ignoredPhotosIsSelecting = false
            self.updateCollectionViewSelectionState()
        }
    }
    
    func updateViewsEnabled() {
        ignoredPhotosViewModel.ignoredPhotosEditable = !model.ignoredPhotos.isEmpty
        selectBarButton.isEnabled = ignoredPhotosViewModel.ignoredPhotosEditable
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        update()
        updateViewsEnabled()
    }
    
    @objc func dismissSelf() {
        dismiss(animated: true)
    }
}
