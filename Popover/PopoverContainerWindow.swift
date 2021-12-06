//
//  PopoverContainerWindow.swift
//  Popover
//
//  Created by Zheng on 12/3/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import SwiftUI

class PopoverContainerWindow: UIWindow {

    var popoverModel: PopoverModel
    
    init(popoverModel: PopoverModel) {
        self.popoverModel = popoverModel
        
        if let scene = UIApplication.shared.connectedScenes.filter({$0.activationState == .foregroundActive}).first as? UIWindowScene {
            super.init(windowScene: scene)
        } else {
            super.init(frame: UIScreen.main.bounds)
        }
        
        self.rootViewController = popoverContainerViewController
        self.windowLevel = .alert
        self.backgroundColor = .clear
        self.makeKeyAndVisible()
    }
    
    lazy var popoverContainerViewController: PopoverContainerViewController = {
        let popoverContainerViewController = PopoverContainerViewController(popoverModel: popoverModel)
        return popoverContainerViewController
    }()
    
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
            
            switch popover.attributes.dismissal.mode {
            case .whenTappedOutside:
                let excludedFrames = popover.attributes.dismissal.excludedFrames()
                if excludedFrames.contains(where: { $0.contains(point) }) {
                    return nil
                }
            case .none:
                break
            }
            
        }
        
        /// otherwise, dismiss and don't pass the event to the popover
        for (index, popover) in popoverModel.popovers.reversed().enumerated() {
            if popover.attributes.dismissal.mode == .whenTappedOutside {
                withAnimation(popover.attributes.dismissal.animation) {
                    popoverModel.popovers.remove(at: index)
                }
            }
        }
        
        
        return nil
    }
}
