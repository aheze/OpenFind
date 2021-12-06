//
//  PopoverModel.swift
//  Popover
//
//  Created by Zheng on 12/3/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import Combine
import SwiftUI

class PopoverModel: ObservableObject {
    @Published var popovers = [Popover]()
    
    /// must be published so that the `PopoverContainerView` rerenders
    @Published internal var popoversDraggable = true
    lazy var draggingEnabled = Binding {
        self.popoversDraggable
    } set: { newValue in
        self.popoversDraggable = newValue
    }
}






