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
        
        
        UIView.animate(withDuration: 2, delay: 0, options: .curveEaseOut, animations: {
            self.numberLabel.fadeTransition(0.3)
            self.numberLabel.text = "\(number)"
        }) { _ in
            
        }
        
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
