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

    var popoverModel: PopoverModel
    var dismiss: (() -> Void)
    
    init(scene: UIWindowScene, popoverModel: PopoverModel, dismiss: @escaping (() -> Void)) {
        self.popoverModel = popoverModel
        self.dismiss = dismiss
        super.init(windowScene: scene)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        for popover in popoverModel.popovers {
            let frame = popover.frame
            print("fr: \(frame) ?? \(point)")
            if frame.contains(point) {
                return super.hitTest(point, with: event)
            }
        }
        
        dismiss()
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
