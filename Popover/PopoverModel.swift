//
//  PopoverModel.swift
//  Popover
//
//  Created by Zheng on 12/3/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import Combine
import SwiftUI


struct Popovers {
    static var window: PopoverContainerWindow?
    static var model: PopoverModel = {
        let model = PopoverModel()
        let window = PopoverContainerWindow(popoverModel: model)
        Popovers.window = window
        
        return model
    }()
    static func setup() {
        _ = model
    }
    
    static func present(_ popover: Popover) {
        
        /// make sure the window is set up the first time
        DispatchQueue.main.async {
            withAnimation(popover.attributes.presentation.animation) {
                Popovers.model.popovers.append(popover)
            }
        }
    }
}

class PopoverModel: ObservableObject {
    @Published var popovers = [Popover]()
    
    @Published internal var popoversDraggable = true
    lazy var draggingEnabled = Binding {
        self.popoversDraggable
    } set: { newValue in
        self.popoversDraggable = newValue
    }
}






