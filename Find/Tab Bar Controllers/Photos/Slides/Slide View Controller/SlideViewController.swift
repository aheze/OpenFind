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
        
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
//        options.isSynchronous = true
        manager.requestImage(for: findPhoto.asset, targetSize: contentView.bounds.size, contentMode: .aspectFit, options: options, resultHandler: { (result, info) in
            print("result, \(info)")
            if let photo = result {
                self.imageView.image = photo
            }
        })
        
        
//        if let url = NSURL.sd_URL(with: findPhoto.asset) {
//            imageView.sd_imageTransition = .fade
//            imageView.sd_setImage(with: url as URL, placeholderImage: nil, options: SDWebImageOptions.fromLoaderOnly, context: [SDWebImageContextOption.storeCacheType: SDImageCacheType.none.rawValue])
//        }
        
    }
}

