//
//  ButtonView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/22/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

class ButtonView: UIButton {
    var tapped: (() -> Void)?
    var touchedDown: ((Bool) -> Void)?
    var shouldFade = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    func configure() {
        addTarget(self, action: #selector(touchDown(_:)), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(touchFinish(_:)), for: [.touchUpInside, .touchCancel, .touchDragExit])
        addTarget(self, action: #selector(touchConfirm(_:)), for: [.touchUpInside, .touchDragEnter])
    }

    @objc func touchDown(_ sender: UIButton) {
        fade(true)
    }

    @objc func touchFinish(_ sender: UIButton) {
        fade(false)
    }

    @objc func touchConfirm(_ sender: UIButton) {
        tapped?()
    }
    
    func fade(_ fade: Bool) {
        touchedDown?(fade)
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
