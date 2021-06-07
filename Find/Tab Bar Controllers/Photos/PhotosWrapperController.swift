//
//  PhotosWrapperController.swift
//  Find
//
//  Created by Zheng on 1/15/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import SnapKit

enum PhotoScreen {
    case photoGallery
    case finding
}
class PhotosNavController: UINavigationController {
    var viewController: PhotosViewController!
}
class PhotosWrapperController: UIViewController {
    var navController = PhotosNavController()
    
    var photosShadowView: UIView?
    var findShadowView: UIView?
    
    var photoFilterState = PhotoFilterState()
//    var currentFilter = PhotoFilter.all
    var photosToFind = [FindPhoto]()
    var findingFromAllPhotos = false
    var hasChangedFromBefore = false
    
    var activeScreen = PhotoScreen.photoGallery
    
    lazy var photoFindViewController: PhotoFindViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "PhotoFindViewController") as? PhotoFindViewController {
            viewController.view.clipsToBounds = true
            viewController.view.layer.cornerRadius = 16
            viewController.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            
            viewController.selfPresented = { [weak self] in
                guard let self = self else { return false }
                return self.activeScreen == .finding
            }
            return viewController
        }
        fatalError()
    }()
    
    var pressedFindBefore = false /// if went to Find mode
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(navController, in: view)
        
        navController.viewController.switchToFind = { [weak self] (photoFilterState, photosToFindFrom, isAllPhotos, hasChangedFromBefore)  in
            guard let self = self else { return }
            print("switching, all? \(isAllPhotos)")
            self.photoFilterState = photoFilterState
            self.photosToFind = photosToFindFrom
            self.findingFromAllPhotos = isAllPhotos
            self.hasChangedFromBefore = hasChangedFromBefore
            self.switchToFind()
        }
        
        navController.viewController.switchBack = { [weak self] in
            guard let self = self else { return }
            self.switchBackToPhotos()
        }

        navController.view.clipsToBounds = true
        
    }
    
    func switchToFind() {
        activeScreen = .finding
        
        let topHeight = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.top ?? 0
        let topShownHeight = topHeight + Constants.photoBottomPreviewHeight
        let translationNeeded = view.bounds.height - topShownHeight
        
        let findOriginY = topShownHeight + 16
        let photoFindFrame = CGRect(x: 0, y: findOriginY, width: view.bounds.width, height: view.bounds.height - findOriginY)
        
        self.addChild(photoFindViewController)
        view.addSubview(photoFindViewController.view)
        photoFindViewController.view.frame = photoFindFrame
        photoFindViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        photoFindViewController.view.frame.origin.y += view.bounds.height
        photoFindViewController.didMove(toParent: self)
        
        if !pressedFindBefore {
            addShadows()
        }
        
        findShadowView?.frame.origin.y += view.bounds.height
        
        navController.viewController.collectionView.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveLinear) {
            
           
            self.navController.view.transform = CGAffineTransform(translationX: 0, y: -translationNeeded)
            self.navController.view.layer.cornerRadius = 16
            self.navController.viewController.shadeView.alpha = 1
            self.navController.viewController.segmentedSlider.alpha = 0
            self.navController.viewController.collapseButton.alpha = 1
            self.photosShadowView?.transform = CGAffineTransform(translationX: 0, y: -translationNeeded)
            self.photosShadowView?.alpha = 1
                        
            self.photoFindViewController.view.frame.origin.y = findOriginY
            self.findShadowView?.frame.origin.y = findOriginY
            self.findShadowView?.alpha = 1
        }
       
        photoFindViewController.populatePhotos(findPhotos: photosToFind, photoFilterState: photoFilterState, findingFromAllPhotos: findingFromAllPhotos, changedFromBefore: hasChangedFromBefore)
        
        pressedFindBefore = true
        
        navController.viewController.extendedCollapseButton.isHidden = false
        
        UIAccessibility.post(notification: .screenChanged, argument: navController.viewController.extendedCollapseButton)
        
    }
    
    func switchBackToPhotos() {
        activeScreen = .photoGallery
        
        navController.viewController.collectionView.isUserInteractionEnabled = true
        photoFindViewController.findBar.searchField.resignFirstResponder()
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveLinear) {
            self.navController.view.transform = CGAffineTransform.identity
            self.navController.view.layer.cornerRadius = 0
            
            self.navController.viewController.shadeView.alpha = 0
            self.navController.viewController.segmentedSlider.alpha = 1
            self.navController.viewController.collapseButton.alpha = 0
            
            self.photosShadowView?.transform = CGAffineTransform.identity
            self.photosShadowView?.alpha = 0
            
            self.photoFindViewController.view.frame.origin.y += self.view.bounds.height
            self.findShadowView?.frame.origin.y += self.view.bounds.height
            self.findShadowView?.alpha = 0
        }
        
        navController.viewController.extendedCollapseButton.isHidden = true
        
        UIAccessibility.post(notification: .screenChanged, argument: navController.viewController.findButton)
        
    }
    
    func addShadows() {
        let photosShadowView = UIView()
        photosShadowView.backgroundColor = .white
        view.addSubview(photosShadowView)
        view.sendSubviewToBack(photosShadowView)
        photosShadowView.frame = navController.view.frame
        
        photosShadowView.layer.shadowColor = UIColor.black.cgColor
        photosShadowView.layer.shadowOpacity = 0.25
        photosShadowView.layer.shadowOffset = .zero
        photosShadowView.layer.shadowRadius = 4
        photosShadowView.layer.cornerRadius = 16
        self.photosShadowView = photosShadowView
        
        let findShadowView = UIView()
        findShadowView.backgroundColor = .white
        view.addSubview(findShadowView)
        view.sendSubviewToBack(findShadowView)
        findShadowView.frame = photoFindViewController.view.frame
        
        findShadowView.layer.shadowColor = UIColor.black.cgColor
        findShadowView.layer.shadowOpacity = 0.25
        findShadowView.layer.shadowOffset = .zero
        findShadowView.layer.shadowRadius = 4
        findShadowView.layer.cornerRadius = 16
        self.findShadowView = findShadowView
    }
}

