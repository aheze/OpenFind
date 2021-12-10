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
        DispatchQueue.main.async {
            withAnimation(popover.attributes.presentation.animation) {
                current.append(popover)
            }
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
            popover.id = current[oldPopoverIndex].id
            
            /// temporarily use the size of the old popover, to have a smooth animation
            popover.context.size = current[oldPopoverIndex].context.size

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
