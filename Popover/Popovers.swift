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
        let transaction = Transaction(animation: popover.attributes.presentation.animation)
        popover.context.transaction = transaction
        withTransaction(transaction) {
            current.append(popover)
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
            var newPopover = newPopover
            let currentContext = current[oldPopoverIndex].context
            
            print("Replacing \(currentContext.size) with \(newPopover.context.size)")
            
            
            newPopover.id = currentContext.id
            
            let transaction = Transaction(animation: newPopover.attributes.presentation.animation)
            newPopover.context.transaction = transaction
            
            if currentContext.size == newPopover.context.size {
                withTransaction(transaction) {
                    newPopover.context.setSize(currentContext.size)
                    current[oldPopoverIndex] = newPopover
                }
            } else {
                newPopover.context.setSize(currentContext.size)
                withTransaction(transaction) {
                    current[oldPopoverIndex] = newPopover
                }
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
    
    /// optional refresh
    static func refresh(with transaction: Transaction? = nil) {
        for popover in current {
            popover.context.transaction = transaction
        }
        model.refresh()
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
