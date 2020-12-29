//
//  TextViewRounded.swift
//  Find
//
//  Created by Andrew on 1/6/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

class RoundedTextView: UITextView {

    let textViewPadding: CGFloat = 7.0

    override func draw(_ rect: CGRect) {
        self.layoutManager.enumerateLineFragments(forGlyphRange: NSMakeRange(0, self.text.count)) { (rect, usedRect, textContainer, glyphRange, Bool) in

            let rect = CGRect(x: usedRect.origin.x, y: usedRect.origin.y + self.textViewPadding, width: usedRect.size.width, height: usedRect.size.height*1.2)
            let rectanglePath = UIBezierPath(roundedRect: rect, cornerRadius: 3)
            UIColor.red.setFill()
            rectanglePath.fill()
        }
    }
}
