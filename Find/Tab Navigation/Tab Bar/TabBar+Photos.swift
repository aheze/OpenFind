//
//  TabBar+Photos.swift
//  Find
//
//  Created by Zheng on 1/9/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

enum PhotoSlideAction {
    case share
    case star
    case cache
    case delete
    case info
    
}
extension TabBarView {
    func showPhotoSelectionControls(show: Bool) {
        if show {
            controlsReferenceView.isUserInteractionEnabled = true
            stackView.isHidden = true
            controlsReferenceView.addSubview(photosControls)
            photosControls.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        } else {
            controlsReferenceView.isUserInteractionEnabled = false
            stackView.isHidden = false
            photosControls.removeFromSuperview()
        }
        
    }
    func showPhotoSlideControls(show: Bool) {
        if show {
            controlsReferenceView.isUserInteractionEnabled = true
            controlsReferenceView.addSubview(photoSlideControls)
            photoSlideControls.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            photoSlideControls.alpha = 0
            UIView.animate(withDuration: 0.3) {
                self.stackView.alpha = 0
                self.photoSlideControls.alpha = 1
            }
            photoSlideControls.isUserInteractionEnabled = true
            
        } else {
            controlsReferenceView.isUserInteractionEnabled = false

            UIView.animate(withDuration: 0.3) {
                self.stackView.alpha = 1
                self.photoSlideControls.alpha = 0
            } completion: { _ in
                self.photoSlideControls.removeFromSuperview()
            }
        }
        
    }
    func dimPhotoSlideControls(dim: Bool, isPhotosControls: Bool) {
        if isPhotosControls {
            if dim {
                photosControls.alpha = 0.5
                photosControls.isUserInteractionEnabled = false
            } else {
                photosControls.alpha = 1
                photosControls.isUserInteractionEnabled = true
            }
        } else {
            if dim {
                photoSlideControls.alpha = 0.5
                photoSlideControls.isUserInteractionEnabled = false
            } else {
                photoSlideControls.alpha = 1
                photoSlideControls.isUserInteractionEnabled = true
            }
        }
    }
    func updateActions(action: ChangeActions, isPhotosControls: Bool) {
        if isPhotosControls {
            switch action {
            case .shouldStar:
                let starImage = UIImage(systemName: "star")
                starButton.setImage(starImage, for: .normal)
            case .shouldNotStar:
                let starFillImage = UIImage(systemName: "star.fill")
                starButton.setImage(starFillImage, for: .normal)
            case .shouldCache:
                let shouldCache = NSLocalizedString("shouldCache", comment: "")
                cacheButton.setTitle(shouldCache, for: .normal)
            case .shouldNotCache:
                let shouldNotCache = NSLocalizedString("shouldNotCache", comment: "")
                cacheButton.setTitle(shouldNotCache, for: .normal)
            }
        } else {
            switch action {
            case .shouldStar:
                let starImage = UIImage(systemName: "star")
                slideStarButton.setImage(starImage, for: .normal)
            case .shouldNotStar:
                let starFillImage = UIImage(systemName: "star.fill")
                slideStarButton.setImage(starFillImage, for: .normal)
            case .shouldCache:
                let shouldCache = NSLocalizedString("shouldCache", comment: "")
                slideCacheButton.setTitle(shouldCache, for: .normal)
            case .shouldNotCache:
                let shouldNotCache = NSLocalizedString("shouldNotCache", comment: "")
                slideCacheButton.setTitle(shouldNotCache, for: .normal)
            }
        }
    }
}
