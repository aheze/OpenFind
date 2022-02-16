//
//  PhotosSlidesItemViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit


class PhotosSlidesItemViewController: UIViewController {
    lazy var scrollZoomController = ScrollZoomViewController.make()
 
    var model: PhotosViewModel
    
    init?(coder: NSCoder, model: PhotosViewModel) {
        self.model = model
        super.init(coder: coder)
    }
    required init?(coder: NSCoder) {
        fatalError("You must create this view controller with metadata.")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = scrollZoomController
        addChildViewController(scrollZoomController, in: view)
        
        if let slidesState = model.slidesState {
            model.imageManager.requestImage(
                for: slidesState.startingPhoto.asset,
                targetSize: .zero,
                contentMode: .aspectFill,
                options: nil
            ) { image, _ in
                self.scrollZoomController.imageView.image = image
            }
        }
    }
}
