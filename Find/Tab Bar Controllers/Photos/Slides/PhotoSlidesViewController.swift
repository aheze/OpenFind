//
//  PhotoSlidesViewController.swift
//  Find
//
//  Created by Zheng on 1/8/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import RealmSwift
import SnapKit

class PhotoSlidesViewController: UIViewController {
    
    // MARK: Paging view controller
    enum ScreenMode { /// show controls or not
        case full, normal
    }
    var currentMode: ScreenMode = .normal
    
    var pageViewController: UIPageViewController {
        return self.children[0] as! UIPageViewController
    }
    
    var currentViewController: SlideViewController {
        return self.pageViewController.viewControllers![0] as! SlideViewController
    }
    
    // MARK: Data source
    var currentIndex = 0
    var firstPlaceholderImage: UIImage? /// from the collection view
    
    // MARK: Nav bar
    var findButton: UIBarButtonItem!
    var titleLabel: UILabel!
    var subtitleLabel: UILabel!
    
    // MARK: Finding
    var slideFindBar: SlideFindBar?
    var slideFindBarTopC: Constraint?
    
    var findPressed = false
    var cameFromFind = false
    var resultPhotos = [ResultPhoto]() /// photos from Finding
    var matchToColors = [String: [CGColor]]()
    
    // MARK: Find from cache
    var numberCurrentlyFindingFromCache = 0 /// how many cache findings are currently going on
    var deviceWidth = UIScreen.main.bounds.width
    
    // MARK: Fast find
//    var currentFastFindProcess: UUID?
    var numberCurrentlyFastFinding = 0
    
    // MARK: Finding back button
    @IBOutlet weak var backButtonView: UIView!
    @IBOutlet weak var backBlurView: UIVisualEffectView!
    @IBAction func backBlurButtonPressed(_ sender: Any) {
        self.transitionController.animator.cameFromFind = true
        self.transitionController.isInteractive = false
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Actions
    let realm = try! Realm()
    var getRealModel: ((EditableHistoryModel) -> HistoryModel?)?
    var updateActions: ((ChangeActions) -> Void)? /// switch star/unstar and cache/uncache
    var findPhotoChanged: ((FindPhoto) -> Void)? /// starred/cached photos
    var deletePhotoFromSlides: ((FindPhoto) -> Void)? /// delete photo
    var checkIfPhotoExists: ((FindPhoto) -> Bool)? /// check if the photo exists in the collection view
    
    // MARK: Transitioning
    var transitionController = ZoomTransitionController()
    
    // MARK: Gestures
    var currentScreenMode = ScreenMode.normal
    var panGestureRecognizer: UIPanGestureRecognizer!
    var singleTapGestureRecognizer: UITapGestureRecognizer!
    var hideTabBar: ((Bool) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDelegates()
        setupGestures()
        setFirstVC()
        setNavigationBar()
        
        
        backBlurView.clipsToBounds = true
        backBlurView.layer.cornerRadius = 6
        
        if !cameFromFind {
            backButtonView.removeFromSuperview()
        }
    }
    
    // MARK: Delegate back to PhotosVC
    weak var updatedIndex: PhotoSlidesUpdatedIndex? /// when scrolled to a new slide
}
