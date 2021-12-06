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
    
    @Published var safeArea: CGRect?
    
    /// must be published so that the `PopoverContainerView` rerenders
    @Published internal var popoversDraggable = true
}






