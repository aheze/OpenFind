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
        let storyboard = UIStoryboard(name: "PhotosContent", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "PhotosViewController") as! PhotosViewController
        self.viewController = viewController
        viewController.loadViewIfNeeded() /// needed to initialize outlets
    }
}
