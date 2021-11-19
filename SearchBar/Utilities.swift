//
//  Utilities.swift
//  SearchBar
//
//  Created by Zheng on 10/14/21.
//

import UIKit

extension Collection {

    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

class ButtonView: UIButton {

    var tapped: (() -> Void)?
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
        self.addTarget(self, action: #selector(touchDown(_:)), for: [.touchDown, .touchDragEnter])
        self.addTarget(self, action: #selector(touchFinish(_:)), for: [.touchUpInside, .touchCancel, .touchDragExit])
        self.addTarget(self, action: #selector(touchConfirm(_:)), for: [.touchUpInside, .touchDragEnter])
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

extension CGFloat {
    var int: Int {
        return Int(self)
    }
}

extension BinaryInteger {
    var degreesToRadians: CGFloat { CGFloat(self) * .pi / 180 }
}

extension FloatingPoint {
    var degreesToRadians: Self { self * .pi / 180 }
    var radiansToDegrees: Self { self * 180 / .pi }
}

extension Int {
    var indexPath: IndexPath {
        return IndexPath(item: self, section: 0)
    }
}
