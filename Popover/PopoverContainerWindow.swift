//
//  PopoverContainerWindow.swift
//  Popover
//
//  Created by Zheng on 12/3/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

class PopoverContainerWindow: UIWindow {
//    var passTroughTag: Int?

    var dismiss: (() -> Void)?
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        dismiss?()
        
        return nil
//        let hitView = super.hitTest(point, with: event)
//
//        if let passTroughTag = passTroughTag {
//            if passTroughTag == hitView?.tag {
//                return nil
//            }
//        }
//        return hitView
    }
}
