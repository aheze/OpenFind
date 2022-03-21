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
    
    lazy var collectionView = UICollectionView()
    lazy var flowLayout = createFlowLayout()
    
    
    init(model: PhotosViewModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        title = "Scanning Photos"
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem.menuButton(self, action: #selector(dismissSelf), imageName: "Dismiss")
        
        /**
         Instantiate the base `view`.
         */
        view = UIView()
    }
    
    @objc func dismissSelf() {
        dismiss(animated: true)
    }
}
