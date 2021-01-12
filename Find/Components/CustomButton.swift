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
    }

    @objc func touchDown(_ sender: UIButton) {
        fade(true)
    }
    @objc func touchFinish(_ sender: UIButton) {
        fade(false)
    }
    func fade(_ fade: Bool) {
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
