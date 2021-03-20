//
//  CameraVC+Buttons.swift
//  FindAppClip1
//
//  Created by Zheng on 3/13/21.
//

import UIKit

extension CameraViewController {
    func configureButtons() {
        shutter.pressed = { [weak self] in
            guard let self = self else { return }
            CurrentState.currentlyPaused.toggle()
            
            /// change UI
            self.shutter.toggle(on: CurrentState.currentlyPaused)
            self.lockFlashlight(lock: CurrentState.currentlyPaused)
            
            /// handle everything else
            self.pausePressed()
            
        }
        
        fullScreenView.clipsToBounds = true
        fullScreenView.layer.cornerRadius = fullScreenView.bounds.height / 2
        fullScreenButton.touched = { [weak self] down in
            if down {
                UIView.animate(withDuration: 0.2, animations: {
                    self?.fullScreenImageView.alpha = 0.5
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self?.fullScreenImageView.alpha = 1
                })
            }
        }
        
        flashView.clipsToBounds = true
        flashView.layer.cornerRadius = flashView.bounds.height / 2
        flashButton.touched = { [weak self] down in
            if down {
                UIView.animate(withDuration: 0.2, animations: {
                    self?.flashImageView.alpha = 0.5
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self?.flashImageView.alpha = 1
                })
            }
        }
        
        showControlsView.alpha = 0
        showControlsView.clipsToBounds = true
        showControlsView.layer.cornerRadius = showControlsView.bounds.height / 2
        
        getButton.touched = { [weak self] down in
            if down {
                UIView.animate(withDuration: 0.2, animations: {
                    self?.morphingLabel.alpha = 0.5
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self?.morphingLabel.alpha = 1
                })
            }
        }
    }
    
    /// lock when preview is paused
    func lockFlashlight(lock: Bool) {
        flashButton.isEnabled = !lock
        flashDisableIcon.animateSlash(lock: lock)
        UIView.animate(withDuration: 0.5) {
            self.flashImageView.alpha = lock ? 0.5 : 1
        }
        
        if CurrentState.flashlightOn {
            if lock {
                toggleFlashlight(false)
            } else {
                toggleFlashlight(true)
            }
        }
    }
    
    func toggleFlashlight(_ on: Bool) {
        guard
            let device = cameraDevice,
            device.hasTorch
        else {
            return
        }

        do {
            try device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            device.unlockForConfiguration()
        } catch {
            print("Torch could not be used: \(error)")
        }
        
        let flashlightImage = on ? UIImage(systemName: "flashlight.on.fill") : UIImage(systemName: "flashlight.off.fill")
        UIView.transition(
            with: flashImageView,
            duration: 0.75,
            options: .transitionCrossDissolve,
            animations: { self.flashImageView.image = flashlightImage },
            completion: nil
        )

        UIView.animate(withDuration: 0.3) {
            self.flashView.backgroundColor = on ? #colorLiteral(red: 0.5, green: 0.4678574155, blue: 0, alpha: 0.75) : UIColor(named: "50Black")
        }
        
    }
}
