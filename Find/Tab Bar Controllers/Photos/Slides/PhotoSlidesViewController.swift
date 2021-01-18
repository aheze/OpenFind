//
//  PhotoSlidesViewController.swift
//  Find
//
//  Created by Zheng on 1/8/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

class PhotoSlidesViewController: UIViewController {
    
    // MARK: Paging view controller
    enum ScreenMode { /// show controls or not
        case full, normal
    }
    var currentMode: ScreenMode = .normal
    
//    weak var deletedPhoto: ZoomDeletedPhoto?
    
    var pageViewController: UIPageViewController {
        return self.children[0] as! UIPageViewController
    }
    
    var currentViewController: SlideViewController {
        return self.pageViewController.viewControllers![0] as! SlideViewController
    }
    
    // MARK: Data source
//    var findPhotos = [FindPhoto]() /// click in Photos
    var currentIndex = 0
    var firstPlaceholderImage: UIImage? /// from the collection view
    
    // MARK: Finding
    var cameFromFind = false
    var resultPhotos = [ResultPhoto]() /// photos from Finding
    var matchToColors = [String: [CGColor]]()
    
    // MARK: Transitioning
    var transitionController = ZoomTransitionController()
    
    // MARK: Gestures
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    // MARK: Actions
    var photoSlideControlPressed: ((PhotoSlideAction) -> Void)? /// pressed action in tab bar
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDelegates()
        setupGestures()
        setFirstVC()
        
        self.title = "Photo"
        navigationItem.largeTitleDisplayMode = .never
    }
    
    // MARK: Delegate back to PhotosVC
    weak var updatedIndex: PhotoSlidesUpdatedIndex? /// when scrolled to a new slide
}
