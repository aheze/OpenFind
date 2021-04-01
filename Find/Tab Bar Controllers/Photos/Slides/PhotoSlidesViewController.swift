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
    
    var presentingInfo: ((Bool) -> Void)? /// update status bar color
    
    @IBOutlet weak var containerView: UIView!
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
    var navigationTitleStackView: UIStackView?
    var titleLabel: UILabel!
    var subtitleLabel: UILabel!
    
    // MARK: Finding
    var slideFindBar: SlideFindBar?
    var slideFindBarTopC: Constraint?
    var continueButtonVisible = false /// if true, set accessibility activate to true
    
    var findPressed = false
    var cameFromFind = false
    var resultPhotos = [ResultPhoto]() /// photos from Finding
    var matchToColors = [String: [HighlightColor]]()
    
    // MARK: Find from cache
    var numberCurrentlyFindingFromCache = 0 /// how many cache findings are currently going on
    var deviceWidth = UIScreen.main.bounds.width
    @IBOutlet weak var messageView: MessageView!
    @IBOutlet weak var messageViewBottomC: NSLayoutConstraint!
    
    // MARK: Fast find
    var numberCurrentlyFastFinding = 0
    
    // MARK: Finding back button
    @IBOutlet weak var backButtonView: UIView!
    @IBOutlet weak var backBlurView: UIVisualEffectView!
    @IBAction func backBlurButtonPressed(_ sender: Any) {
        self.transitionController.animator.cameFromFind = true
        self.transitionController.isInteractive = false
        self.dismiss(animated: true, completion: nil)
    }
    
    /// Force status bar hidden
    override var prefersStatusBarHidden: Bool {
        if isForcingStatusBarHidden {
            return true
        } else {
            if currentScreenMode == .normal {
                return false
            } else {
                return true
            }
        }
    }
    
    // MARK: Actions
    let realm = try! Realm()
    var imageToShare: UIImage?
    var getRealModel: ((EditableHistoryModel) -> HistoryModel?)?
    var updateActions: ((ChangeActions) -> Void)? /// switch star/unstar and cache/uncache
    var findPhotoChanged: ((FindPhoto) -> Void)? /// starred/cached photos
    var deletePhotoFromSlides: ((FindPhoto) -> Void)? /// delete photo
    var checkIfPhotoExists: ((FindPhoto) -> Bool)? /// check if the photo exists in the collection view
    
    // MARK: Caching
    var currentCachingIdentifier: UUID?
    var temporaryCachingPhoto: TemporaryCachingPhoto?
    var currentProgress = CGFloat(0) /// how much cache is finished
    var focusCacheButton: (() -> Void)?
    
    // MARK: Transitioning
    var transitionController = ZoomTransitionController()
    
    // MARK: Gestures
    var currentScreenMode = ScreenMode.normal
    var panGestureRecognizer: UIPanGestureRecognizer!
    var singleTapGestureRecognizer: UITapGestureRecognizer!
    var hideTabBar: ((Bool) -> Void)?
    @IBOutlet weak var voiceOverSlidesControl: VoiceOverSlidesControl!
    @IBOutlet weak var voiceOverBottomC: NSLayoutConstraint!
    
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
        
        messageViewBottomC.constant = CGFloat(ConstantVars.tabHeight) + 16
        
        voiceOverSlidesControl.isHidden = true
        
        setupAccessibility()
        
        observeVoiceOverChanges()
    }
    
    // MARK: Delegate back to PhotosVC
    weak var updatedIndex: PhotoSlidesUpdatedIndex? /// when scrolled to a new slide
}
