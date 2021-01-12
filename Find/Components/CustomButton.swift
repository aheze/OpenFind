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
        print("mode: \(String(describing: imageView?.contentMode))")
        
        if let mode = imageView?.contentMode {
            switch mode {

            case .scaleToFill:
                print("mode is scaleToFill")
            case .scaleAspectFit:
                print("mode is scaleAspectFit")
            case .scaleAspectFill:
                print("mode is scaleAspectFill")
            case .redraw:
                print("mode is redraw")
            case .center:
                print("mode is center")
            case .top:
                print("mode is top")
            case .bottom:
                print("mode is bottom")
            case .left:
                print("mode is left")
            case .right:
                print("mode is right")
            case .topLeft:
                print("mode is topLeft")
            case .topRight:
                print("mode is topRight")
            case .bottomLeft:
                print("mode is bottomLeft")
            case .bottomRight:
                print("mode is bottomRight")
            @unknown default:
                print("def")
            }
        }
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
