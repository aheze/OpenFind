//
//  IconPickerViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/25/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

class IconPickerViewController: UIViewController {

    var model = IconPickerViewModel()
    @IBOutlet weak var collectionView: UICollectionView!
    
    static func make(model: IconPickerViewModel) -> (UINavigationController, IconPickerViewController) {
        let storyboard = UIStoryboard(name: "ListsContent", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "IconPickerViewController") { coder in
            IconPickerViewController(coder: coder, model: model)
        }
        let navigationController = UINavigationController(rootViewController: viewController)
        return (navigationController, viewController)
    }
    
    init?(
        coder: NSCoder,
        model: IconPickerViewModel
    ) {
        self.model = model
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)


        
        self.title = "Icons"
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem.menuButton(self, action: #selector(self.dismissSelf), imageName: "Dismiss")
    }
    
    @objc func dismissSelf() {
        self.dismiss(animated: true)
    }
    
}
