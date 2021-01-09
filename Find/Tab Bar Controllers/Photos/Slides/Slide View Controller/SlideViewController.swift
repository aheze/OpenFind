//
//  SlideViewController.swift
//  Find
//
//  Created by Zheng on 1/9/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
//import SDWebImage
//import SDWebImagePhotosPlugin
import Photos

/// each slide in the slides
class SlideViewController: UIViewController {
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    var placeholderImage: UIImage? /// placeholder from the collection view
    var findPhoto = FindPhoto()
    var index: Int = 0 /// index of this slide
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        scrollView.contentInsetAdjustmentBehavior = .never
        
        imageView.image = placeholderImage
        
        let scale = UIScreen.main.scale
        let targetSize = CGSize(width: contentView.bounds.width * scale, height: contentView.bounds.height * scale)
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        manager.requestImage(for: findPhoto.asset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { (result, info) in
            if let photo = result {
                self.imageView.image = photo
            }
        })
    }
}

