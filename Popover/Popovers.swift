//
//  Popovers.swift
//  Popover
//
//  Created by Zheng on 12/5/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

struct Popovers {
    static var window: PopoverContainerWindow?
    static internal var model: PopoverModel = {
        let model = PopoverModel()
        let window = PopoverContainerWindow(popoverModel: model)
        Popovers.window = window
        
        return model
    }()
    
    static func present(_ popover: Popover) {
        
        /// make sure the window is set up the first time
        withAnimation(popover.attributes.presentation.animation) {
            current.append(popover)
            
            //                let context = current[oldPopoverIndex].context
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                
//                popover.context.setSize(<#T##size: CGSize?##CGSize?#>)
//                print("sie: \(popover.context.size)")
//                if let popoverSize = popover.context.size {
//                    let popoverFrame = popover.context.position.popoverFrame(popoverSize: popoverSize)
//                    print("New: \(popoverFrame)")
//                    popover.context.frame = popoverFrame
//                }
//            }
            //                popover.context = context
        }
    }
    
    static func dismiss(_ popover: Popover) {
        if let popoverIndex = index(of: popover) {
            withAnimation(popover.attributes.dismissal.animation) {
                _ = current.remove(at: popoverIndex)
            }
        }
    }
    
    static func replace(_ oldPopover: Popover, with newPopover: Popover) {
        if let oldPopoverIndex = index(of: oldPopover) {
            var popover = newPopover            
            let context = current[oldPopoverIndex].context

            popover.id = context.id
            popover.context.setSize(context.size, animation: newPopover.attributes.presentation.animation)
            
            withAnimation(newPopover.attributes.presentation.animation) {
                current[oldPopoverIndex] = popover
            }
        }
    }
    
    static var current: [Popover] {
        get {
            model.popovers
        } set {
            model.popovers = newValue
        }
    }
    
    static func popover(tagged tag: String) -> Popover? {
        return current.first(where: { $0.attributes.tag == tag })
    }
    static func index(of popover: Popover) -> Int? {
        return current.indices.first(where: { current[$0] == popover })
    }
    
    static var draggingEnabled: Bool {
        get {
            Popovers.model.popoversDraggable
        } set {
            Popovers.model.popoversDraggable = newValue
        }
    }
}
