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
            
            /// check if hit a popover
            let frame = popover.frame
            if frame.contains(point) {
                return super.hitTest(point, with: event)
            }
            
            /// check if hit a excluded view - don't dismiss
            if popover.keepPresentedRects.contains(where: { $0.contains(point) }) {
                return nil
            }
        }
        
        /// otherwise, dismiss and don't pass the event to the popover
        dismiss()
        return nil
    }
}
