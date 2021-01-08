//
//  PhotosVC+PHAssets.swift
//  Find
//
//  Created by Zheng on 1/4/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import Photos
import SnapKit

extension PhotosViewController {
    func fetchAssets() {
        let status: PHAuthorizationStatus
        if #available(iOS 14, *) {
            status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        } else {
            status = PHPhotoLibrary.authorizationStatus()
        }
        
        var permissionAction = PermissionAction.notDetermined
        switch status {
        case .notDetermined:
            permissionAction = .notDetermined
        case .restricted:
            permissionAction = .restricted
        case .denied:
            permissionAction = .goToSettings
        case .authorized:
            permissionAction = .allowed
        case .limited:
            permissionAction = .allowed
        @unknown default:
            print("unknown default")
        }
        
        if permissionAction != .allowed {
            showPermissionView(action: permissionAction)
        } else {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            
            if let photos = allPhotos {
                
                var totalMonths = [Month]()
                
                var mutableMonths = [MutableMonth]()
                
                photos.enumerateObjects { (asset, index, stop) in
                    
                    var matchingRealmPhoto: HistoryModel?
                    if let photoObjects = self.photoObjects {
                        for object in photoObjects {
                            if object.assetIdentifier == asset.localIdentifier {
                                matchingRealmPhoto = object
                                break
                            }
                        }
                    }
                    
                    let findPhoto = FindPhoto()
                    if let matchingPhoto = matchingRealmPhoto {
                        findPhoto.model = matchingPhoto
                    }
                    findPhoto.asset = asset
                    
                    if let photoDateCreated = asset.creationDate {
                        let sameMonths = mutableMonths.filter( { $0.monthDate.isEqual(to: photoDateCreated, toGranularity: .month) })
                        if let firstOfSameMonth = sameMonths.first {
                            firstOfSameMonth.photos.append(findPhoto)
                        } else {
                            let newMonth = MutableMonth()
                            newMonth.monthDate = photoDateCreated
                            newMonth.photos.append(findPhoto)
                            mutableMonths.append(newMonth)
                        }
                    }
                }
                
                for mutableMonth in mutableMonths {
                    let realMonth = Month(monthDate: mutableMonth.monthDate, photos: mutableMonth.photos)
                    totalMonths.append(realMonth)
                }
                
                allMonths = totalMonths
                monthsToDisplay = totalMonths
                applySnapshot(animatingDifferences: false)
            }
        }
    }
    
    func showPermissionView(action: PermissionAction) {
        
        collectionView.alpha = 0
        
        let permissionView = PhotoPermissionView()
        permissionView.permissionAction = action
        view.addSubview(permissionView)
        permissionView.snp.makeConstraints { (make) in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        permissionView.allowed = { [weak self] fullAccess in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5, animations: {
                    permissionView.alpha = 0
                    self.collectionView.alpha = 1
                }) { _ in
                    permissionView.removeFromSuperview()
                }
                self.hasFullAccess = fullAccess
                self.fetchAssets()
            }
            
        }
    }
    
}
