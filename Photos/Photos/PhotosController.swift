//
//  PhotosController.swift
//  Photos
//
//  Created by Zheng on 11/18/21.
//

import UIKit

public class PhotosController {
    public var viewController: PhotosViewController
    
    init() {
        let bundle = Bundle(identifier: "com.aheze.Photos")
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        let viewController = storyboard.instantiateViewController(withIdentifier: "PhotosViewController") as! PhotosViewController
        self.viewController = viewController
        viewController.loadViewIfNeeded() /// needed to initialize outlets
    }
}
