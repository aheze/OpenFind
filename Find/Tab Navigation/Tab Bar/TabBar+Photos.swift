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
            photosControls.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            backgroundView.accessibilityLabel = "Toolbar"
        } else {
            controlsReferenceView.isUserInteractionEnabled = false
            stackView.isHidden = false
            photosControls.removeFromSuperview()
            
            backgroundView.accessibilityLabel = "Tab bar"
        }
    }

    func showPhotoSlideControls(show: Bool) {
        if show {
            controlsReferenceView.isUserInteractionEnabled = true
            
            if !photoSlideControls.isDescendant(of: controlsReferenceView) {
                controlsReferenceView.addSubview(photoSlideControls)
                photoSlideControls.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
            }
            
            photoSlideControls.alpha = 0
            UIView.animate(withDuration: 0.3) {
                self.stackView.alpha = 0
                self.photoSlideControls.alpha = 1
            }
            photoSlideControls.isUserInteractionEnabled = true
            
            backgroundView.accessibilityLabel = "Toolbar"
            
        } else {
            controlsReferenceView.isUserInteractionEnabled = false

            UIView.animate(withDuration: 0.3) {
                self.stackView.alpha = 1
                self.photoSlideControls.alpha = 0
            } completion: { _ in
                if !self.controlsReferenceView.isUserInteractionEnabled {
                    self.photoSlideControls.removeFromSuperview()
                }
            }
            
            backgroundView.accessibilityLabel = "Tab bar"
        }
    }

    func dimPhotoSlideControls(dim: Bool, isPhotosControls: Bool) {
        if isPhotosControls {
            if dim {
                photosControls.alpha = 0.5
                photosControls.isUserInteractionEnabled = false
                
                starButton.isEnabled = false
                cacheButton.isEnabled = false
                photosDeleteButton.isEnabled = false
            } else {
                photosControls.alpha = 1
                photosControls.isUserInteractionEnabled = true
                
                starButton.isEnabled = true
                cacheButton.isEnabled = true
                photosDeleteButton.isEnabled = true
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
    
    func updateNumberOfSelectedPhotos(to number: Int) {
        numberOfSelectedPhotos = number
        
        let starText = shouldStarSelectedPhotos ? "Star" : "Unstar"
        let cacheText = shouldCacheSelectedPhotos ? "Cache" : "Uncache"
        
        starButton.accessibilityLabel = shouldStarSelectedPhotos ? "Star" : "Starred"
        cacheButton.accessibilityLabel = shouldCacheSelectedPhotos ? "Cache" : "Cached"
        
        if number == 1 {
            starButton.accessibilityHint = "\(starText) \(number) selected photo"
            cacheButton.accessibilityHint = "\(cacheText) \(number) selected photo"
            photosDeleteButton.accessibilityHint = "Delete \(number) selected photo"
        } else if number == 0 {
            starButton.accessibilityHint = "Select photos first."
            cacheButton.accessibilityHint = "Select photos first."
            photosDeleteButton.accessibilityHint = "Select photos first."
        } else {
            starButton.accessibilityHint = "\(starText) \(number) selected photos"
            cacheButton.accessibilityHint = "\(cacheText) \(number) selected photos"
            photosDeleteButton.accessibilityHint = "Delete \(number) selected photos"
        }
    }
    
    func updateActions(action: ChangeActions, isPhotosControls: Bool) {
        if isPhotosControls {
            switch action {
            case .shouldStar:
                let starImage = UIImage(systemName: "star")
                starButton.setImage(starImage, for: .normal)
                shouldStarSelectedPhotos = true
            case .shouldNotStar:
                let starFillImage = UIImage(systemName: "star.fill")
                starButton.setImage(starFillImage, for: .normal)
                shouldStarSelectedPhotos = false
            case .shouldCache:
                let shouldCache = NSLocalizedString("shouldCache", comment: "")
                cacheButton.setTitle(shouldCache, for: .normal)
                shouldCacheSelectedPhotos = true
            case .shouldNotCache:
                let shouldNotCache = NSLocalizedString("shouldNotCache", comment: "")
                cacheButton.setTitle(shouldNotCache, for: .normal)
                shouldCacheSelectedPhotos = false
            case .currentlyCaching:
                break
            }
            
            /// refresh accessibility
            let howManyPhotos = numberOfSelectedPhotos
            updateNumberOfSelectedPhotos(to: howManyPhotos)
        } else {
            switch action {
            case .shouldStar:
                let starImage = UIImage(systemName: "star")
                slideStarButton.setImage(starImage, for: .normal)
                
                slideStarButton.accessibilityLabel = "Star"
                slideStarButton.accessibilityHint = "Tap to star this photo"
            case .shouldNotStar:
                let starFillImage = UIImage(systemName: "star.fill")
                slideStarButton.setImage(starFillImage, for: .normal)
                
                slideStarButton.accessibilityLabel = "Starred"
                slideStarButton.accessibilityHint = "Tap to unstar this photo"
            case .shouldCache:
                let shouldCache = NSLocalizedString("shouldCache", comment: "")
                slideCacheButton.setTitle(shouldCache, for: .normal)
                
                slideCacheButton.accessibilityLabel = "Cache"
                slideCacheButton.accessibilityHint = "Cache this photo. Produces much more accurate results during finding."
            case .shouldNotCache:
                let shouldNotCache = NSLocalizedString("shouldNotCache", comment: "")
                slideCacheButton.setTitle(shouldNotCache, for: .normal)
                
                slideCacheButton.accessibilityLabel = "Cached"
                slideCacheButton.accessibilityHint = "Tap to uncache this photo"
            case .currentlyCaching:
                let shouldNotCache = NSLocalizedString("caching...", comment: "")
                slideCacheButton.setTitle(shouldNotCache, for: .normal)
                
                slideCacheButton.accessibilityLabel = "Caching"
                slideCacheButton.accessibilityHint = "Caching currently in progress"
            }
        }
    }
}
