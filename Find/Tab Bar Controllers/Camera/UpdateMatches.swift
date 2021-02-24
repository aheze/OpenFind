//
//  UpdateMatches.swift
//  Find
//
//  Created by Andrew on 11/10/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

extension CameraViewController {
    func updateMatchesNumber(to number: Int) {
        currentNumberOfMatches = number
        updateStatsNumber?.update(to: number)
        
        if number > previousNumberOfMatches {
            if currentPassCount >= 100 {
                currentPassCount = 0
                
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
            }
        }
        
        DispatchQueue.main.async {
//            UIView.transition(with: self.statsButton, duration: 0.1, options: .transitionCrossDissolve, animations: {
//                self.statsButton.setTitle("\(number)", for: .normal)
                self.statsLabel.text = "\(number)"
//            })
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
