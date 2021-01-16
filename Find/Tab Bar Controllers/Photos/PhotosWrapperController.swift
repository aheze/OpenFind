//
//  PhotosWrapperController.swift
//  Find
//
//  Created by Zheng on 1/15/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

class PhotosNavController: UINavigationController {
    var viewController: PhotosViewController!
}
class PhotosWrapperController: UIViewController {
    var navController = PhotosNavController()
    
    var photosToFind = [FindPhoto]()
    lazy var photoFindViewController: PhotoFindViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "PhotoFindViewController") as? PhotoFindViewController {
            viewController.view.clipsToBounds = true
            viewController.view.layer.cornerRadius = 16
            viewController.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            return viewController
        }
        fatalError()
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(navController, in: view)
        
        navController.viewController.switchToFind = { [weak self] (currentFilter, photosToFindFrom)  in
            guard let self = self else { return }
            self.photosToFind = photosToFindFrom
            
            
            self.switchToFind()
        }
    }
    
    func switchToFind() {
        photoFindViewController.populatePhotos(findPhotos: photosToFind)
        self.addChild(photoFindViewController)
        view.addSubview(photoFindViewController.view)
        photoFindViewController.view.frame = view.bounds
        photoFindViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        photoFindViewController.view.frame.origin.y += view.bounds.height
        photoFindViewController.didMove(toParent: self)
        
        let topHeight = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.top ?? 0
        let topShownHeight = topHeight + Constants.photoBottomPreviewHeight
        let translationNeeded = view.bounds.height - topShownHeight
        
        let findOriginY = topShownHeight + 16
        
        addShadow(add: true)
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveLinear) {
            self.navController.view.transform = CGAffineTransform(translationX: 0, y: -translationNeeded)
            self.navController.view.layer.cornerRadius = 16
            self.photoFindViewController.view.frame.origin.y = findOriginY
        } completion: { _ in
            print("complete")
        }
    }
    
    func addShadow(add: Bool) {
        if add {
            navController.view.layer.shadowColor = UIColor.black.cgColor
            navController.view.layer.shadowOpacity = 0.5
            navController.view.layer.shadowOffset = .zero
            navController.view.layer.shadowRadius = 4
        } else {
            navController.view.layer.shadowColor = UIColor.clear.cgColor
        }
    }
}

