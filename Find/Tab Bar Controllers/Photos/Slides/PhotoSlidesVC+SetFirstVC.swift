//
//  PhotoSlidesVC+SetFirstVC.swift
//  Find
//
//  Created by Zheng on 1/8/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension PhotoSlidesViewController {
    func setFirstVC() {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SlideViewController") as! SlideViewController
        
        let findPhoto = findPhotos[currentIndex]
        viewController.findPhoto = findPhoto
        viewController.index = currentIndex
        viewController.placeholderImage = firstPlaceholderImage
        
        let viewControllers = [ viewController ]
            
        self.pageViewController.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
    }
}
