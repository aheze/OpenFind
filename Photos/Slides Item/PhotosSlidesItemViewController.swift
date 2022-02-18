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
    var findPhoto: FindPhoto
    
    @IBOutlet var containerView: UIView!
    
    init?(coder: NSCoder, model: PhotosViewModel, findPhoto: FindPhoto) {
        self.model = model
        self.findPhoto = findPhoto
        super.init(coder: coder)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("You must create this view controller with metadata.")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = scrollZoomController
        addChildViewController(scrollZoomController, in: containerView)
        reloadImage()
        containerView.alpha = 0
    }

    func reloadImage() {
        if let image = findPhoto.image {
            scrollZoomController.imageView.image = image
        } else {
            model.imageManager.requestImage(
                for: findPhoto.photo.asset,
                targetSize: .zero,
                contentMode: .aspectFill,
                options: nil
            ) { [weak self] image, _ in
                self?.findPhoto.image = image
                self?.scrollZoomController.imageView.image = self?.findPhoto.image
            }
        }
    }
}
