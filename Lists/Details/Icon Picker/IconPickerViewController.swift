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
    
    static func make(model: IconPickerViewModel) -> IconPickerViewController {
        let storyboard = UIStoryboard(name: "ListsContent", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "IconPickerViewController") { coder in
            IconPickerViewController(coder: coder, model: model)
        }
        return viewController
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
    }
    
}
