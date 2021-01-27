//
//  CameraVC+ButtonSetup.swift
//  Find
//
//  Created by Zheng on 1/24/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import Photos

enum PhotoPermissionAction {
    case shouldAsk
    case shouldGoToSettings
    case allowed
}
extension CameraViewController {
    
    func setupCameraButtons() {
        cameraIconHolder.backgroundColor = UIColor.clear
        cameraIcon.isActualButton = true
        cameraIcon.pressed = { [weak self] in
            guard let self = self else { return }
            

            
            CameraState.isPaused.toggle()
            self.cameraIcon.toggle(on: CameraState.isPaused)
            self.cameraChanged?(CameraState.isPaused)
            
            if CameraState.isPaused {
                self.pauseLivePreview()
                //            let hasPausedBefore = self.defaults.bool(forKey: "hasPausedBefore")
                if !false {
                    //                self.defaults.set(true, forKey: "hasPausedBefore")
                    self.showCacheTip()
                }
            } else {
                if let cacheTipView = self.cacheTipView {
                    cacheTipView.dismiss()
                }
                self.saveToPhotosIfNeeded()
                self.resetState()
                self.startLivePreview()
                
            }
        }
        saveToPhotos.alpha = 0
        saveToPhotos.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        cache.alpha = 0
        cache.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        saveLabel.alpha = 0
        cacheLabel.alpha = 0
        
        saveToPhotos.pressed = { [weak self] in
            guard let self = self else { return }
            
            let status = self.checkAuthorizationStatus()
            
            if status == .allowed {
                self.savePressed.toggle()
            } else {
                if status == .shouldAsk {
                    self.requestAuthorization {
                        DispatchQueue.main.async {
                            self.savePressed.toggle()
                            self.animatePhotosIcon()
                        }
                    }
                } else if status == .shouldGoToSettings {
                    let alert = UIAlertController(title: "Allow Access to Photo Library", message: "Find needs permission to save photos", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
                    alert.addAction(UIAlertAction(title: "Go to Settings", style: UIAlertAction.Style.default, handler: { _ in
                        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                            return
                        }
                        if UIApplication.shared.canOpenURL(settingsUrl) {
                            UIApplication.shared.open(settingsUrl)
                        }
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
            self.animatePhotosIcon()
        }
        cache.pressed = { [weak self] in
            guard let self = self else { return }
            self.cachePressed.toggle()
            if self.cachePressed {
                self.beginCachingPhoto()
            } else {
                self.cache.cacheIcon.animateCheck(percentage: 0)
                self.cache.cacheIcon.toggleRim(light: false)
                self.cacheLabel.fadeTransition(0.2)
                self.cacheLabel.text = "Cache"
                self.messageView.hideMessages()
            }
        }
    }
    
    func checkAuthorizationStatus() -> PhotoPermissionAction {
        var action = PhotoPermissionAction.shouldGoToSettings
        if #available(iOS 14, *) {
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            if status == .authorized || status == .limited {
                action = .allowed
            } else if status == .notDetermined {
                action = .shouldAsk
            } else {
                action = .shouldGoToSettings
            }
            
        } else {
            let status = PHPhotoLibrary.authorizationStatus()
            if status == .authorized {
                action = .allowed
            } else if status == .notDetermined {
                action = .shouldAsk
            } else {
                action = .shouldGoToSettings
            }
        }
        
        return action
    }
    
    func requestAuthorization(completion: @escaping (() -> Void)) {
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { (status) in
                if status == .authorized || status == .limited {
                    completion()
                }
            }
        } else {
            PHPhotoLibrary.requestAuthorization { (status) in
                if status == .authorized {
                    completion()
                }
            }
        }
    }
}
