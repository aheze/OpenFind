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
        DispatchQueue.main.async {
            print("Updating matches number to \(number)")
            if number == 0 {
                self.upButton.isEnabled = false
                self.downButton.isEnabled = false
            } else {
                self.upButton.isEnabled = true
                self.downButton.isEnabled = true
            }
        
    //        else if number - 1 == tempComponents.count {
    //            downButton.isEnabled = false
    //        } else {
    //            upButton.isEnabled = true
    //            downButton.isEnabled = true
    //        }
            self.numberDenomLabel.fadeTransition(0.3)
            self.numberDenomLabel.text = "\(number)"
        }
    }
    func hideTopNumber(hide: Bool) {
        
        var xMove = 6
        var yMove = 14
        if hide == true {
            xMove = 0
            yMove = 0
            slashImage.alpha = 1
        } else {
            slashImage.alpha = 0
        }
        
        matchesBig.bringSubviewToFront(numberDenomLabel)
        matchesBig.bringSubviewToFront(numberLabel)
        for constraint in matchesBig.constraints {
            if constraint.identifier == "numberY" {
               constraint.constant = CGFloat(-yMove)
            }
            if constraint.identifier == "denomY" {
                constraint.constant = CGFloat(yMove)
            }
            if constraint.identifier == "numberX" {
                constraint.constant = CGFloat(-xMove)
            }
            if constraint.identifier == "denomX" {
                constraint.constant = CGFloat(xMove)
            }
        }
        
        matchesBig.bringSubviewToFront(slashImage)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            if hide == true {
                self.numberLabel.alpha = 0
                self.slashImage.alpha = 0
            } else {
                self.numberLabel.alpha = 1
                self.slashImage.alpha = 1
            }
            self.matchesBig.layoutIfNeeded()
        }, completion: nil)
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
