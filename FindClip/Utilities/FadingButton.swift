//
//  FadingButton.swift
//  FindAppClip1
//
//  Created by Zheng on 3/13/21.
//

import UIKit

class FadingButton: UIButton {
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
        imageView?.contentMode = .scaleAspectFit
        contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
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
                    self.imageView?.alpha = 0.5
                    self.titleLabel?.alpha = 0.5
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.imageView?.alpha = 1
                    self.titleLabel?.alpha = 1
                })
            }
        }
    }
}
