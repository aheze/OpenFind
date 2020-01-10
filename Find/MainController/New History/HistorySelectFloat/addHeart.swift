//
//  addHeart.swift
//  Find
//
//  Created by Andrew on 1/8/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

extension HPhotoCell {
    
    func addHeart(add: Bool) {
        if add == true {
            UIView.animate(withDuration: 0.4, animations: {
                self.heartView.alpha = 1
                self.heartView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            })
        } else {
            UIView.animate(withDuration: 0.4, animations: {
                self.heartView.alpha = 0
                self.heartView.transform = .identity
            })
        }
    }
}
