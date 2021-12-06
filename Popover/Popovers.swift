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
    static var model: PopoverModel = {
        let model = PopoverModel()
        let window = PopoverContainerWindow(popoverModel: model)
        Popovers.window = window
        
        return model
    }()
    
    static func present(_ popover: Popover) {
//        print("sa: \(model.safeArea)")
        
        /// make sure the window is set up the first time
        DispatchQueue.main.async {
            withAnimation(popover.attributes.presentation.animation) {
                Popovers.model.popovers.append(popover)
            }
        }
    }
    
    
    static var draggingEnabled = Binding {
        Popovers.model.popoversDraggable
    } set: { newValue in
        Popovers.model.popoversDraggable = newValue
    }
    
    static var safeArea = Binding {
        Popovers.model.safeArea
    } set: { newValue in
        Popovers.model.safeArea = newValue
    }
    
}
