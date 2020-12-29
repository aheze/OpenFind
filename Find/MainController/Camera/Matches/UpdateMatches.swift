//
//  UpdateMatches.swift
//  Find
//
//  Created by Andrew on 11/10/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

extension ViewController {
    
    
    func updateMatchesNumber(to number: Int) {
        
        currentNumberOfMatches = number
        updateStatsNumber?.update(to: number)
        
        if number > previousNumberOfMatches {
            if currentPassCount >= 100 {
                currentPassCount = 0
                if shouldHapticFeedback {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.prepare()
                    generator.impactOccurred()
                }
            }
        }
        
        DispatchQueue.main.async {
            self.numberLabel.fadeTransition(0.1)
            self.numberLabel.text = "\(number)"
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
