//
//  CustomButton.swift
//  Find
//
//  Created by Zheng on 1/11/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

class CustomButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
        configure()
    }

    func configure() {
        self.addTarget(self, action: #selector(touchDown(_:)), for: [.touchDown, .touchDragEnter])
        self.addTarget(self, action: #selector(touchFinish(_:)), for: [.touchUpInside, .touchCancel, .touchDragExit])
        imageView?.contentMode = .scaleAspectFit
        self.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }

    @objc func touchDown(_ sender: UIButton) {
        touched?(true)
        fade(true)
    }
    @objc func touchFinish(_ sender: UIButton) {
        touched?(false)
        fade(false)
    }
    
    var touched: ((Bool) -> Void)? /// True if Down
    var shouldFade = true
    
    func fade(_ fade: Bool) {
        if shouldFade {
            if fade {
                UIView.animate(withDuration: 0.2, animations: {
                    self.alpha = 0.5
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.alpha = 1
                })
            }
        }
    }
}
