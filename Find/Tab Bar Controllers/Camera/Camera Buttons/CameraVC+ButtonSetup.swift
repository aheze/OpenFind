//
//  CameraVC+ButtonSetup.swift
//  Find
//
//  Created by Zheng on 1/24/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension CameraViewController {
    func setupCameraButtons() {
        cameraIconHolder.backgroundColor = UIColor.clear
        cameraIcon.isActualButton = true
        cameraIcon.pressed = { [weak self] in
            guard let self = self else { return }
            CameraState.isOn.toggle()
            self.cameraIcon.toggle(on: CameraState.isOn)
            self.cameraChanged?(CameraState.isOn)
        }
        saveToPhotos.alpha = 0
        saveToPhotos.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        cache.alpha = 0
        cache.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        saveLabel.alpha = 0
        cacheLabel.alpha = 0
        
        saveToPhotos.pressed = { [weak self] in
            guard let self = self else { return }
            self.savePressed.toggle()
            if self.savePressed {
                UIView.animate(withDuration: Double(Constants.transitionDuration)) {
                    self.saveToPhotos.photosIcon.makeActiveState(offset: true)()
                }
                self.saveLabel.fadeTransition(0.2)
                self.saveLabel.text = "Saved"
            } else {
                UIView.animate(withDuration: Double(Constants.transitionDuration)) {
                    self.saveToPhotos.photosIcon.makeNormalState(details: Constants.detailIconColorDark, foreground: Constants.foregroundIconColorDark, background: Constants.backgroundIconColorDark)()
                }
                self.saveLabel.fadeTransition(0.2)
                self.saveLabel.text = "Save"
            }
        }
        cache.pressed = { [weak self] in
            guard let self = self else { return }
            self.cachePressed.toggle()
            if self.cachePressed {
                self.cache.cacheIcon.animateCheck(percentage: 1)
                self.cache.cacheIcon.toggleRim(light: true)
                self.cacheLabel.fadeTransition(0.2)
                self.cacheLabel.text = "Caching..."
                self.messageView.showMessage("Caching - 50%", dismissible: false, duration: -1)
            } else {
                self.cache.cacheIcon.animateCheck(percentage: 0)
                self.cache.cacheIcon.toggleRim(light: false)
                self.cacheLabel.fadeTransition(0.2)
                self.cacheLabel.text = "Cache"
                self.messageView.showMessage("Cancelled", dismissible: true, duration: 1)
            }
        }
    }
}
