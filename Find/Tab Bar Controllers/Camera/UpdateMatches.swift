//
//  UpdateMatches.swift
//  Find
//
//  Created by Andrew on 11/10/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

extension CameraViewController {
    func updateMatchesNumber(to number: Int, tapHaptic: Bool) {
        currentNumberOfMatches = number
        
        statsNavController.viewController.update(to: number)
        statsView.accessibilityValue = "\(number) results"
        
        if statsFocused {
            
            if statsShouldAnnounce {
                UIAccessibility.post(notification: .announcement, argument: "\(number)")
            }
            
            if number == 0 {
                statsShouldAnnounce = false
            } else {
                statsShouldAnnounce = true
            }
        }
        
        if tapHaptic {
            switch UserDefaults.standard.integer(forKey: "hapticFeedbackLevel") {
            case 2:
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.prepare()
                generator.impactOccurred()
            case 3:
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.prepare()
                generator.impactOccurred()
            default:
                break
            }
            
            if CameraState.isPaused {
                UIAccessibility.post(notification: .announcement, argument: "\(number) results found.")
            } else {
                UIAccessibility.post(notification: .announcement, argument: "\(number) results found. Double-tap the shutter to pause.")
            }
        }
        
        DispatchQueue.main.async {
            self.statsLabel.text = "\(number)"
        }
        
        previousNumberOfMatches = number
    }

}
extension UIView {
    func fadeTransition(_ duration:CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.fade.rawValue)
    }
}
