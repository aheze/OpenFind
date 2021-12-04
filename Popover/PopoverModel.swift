//
//  PopoverModel.swift
//  Popover
//
//  Created by Zheng on 12/3/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import Combine
import UIKit

class PopoverModel: ObservableObject {
    @Published var fieldSettings: Popover.FieldSettings?
    var fieldSettingsChanged: ((Popover.FieldSettings?) -> Void)? /// pass in old value
}

protocol PopoverContext {
    var origin: CGPoint { get set }
}
struct Popover {
    struct FieldSettings: PopoverContext {
        var origin: CGPoint = .zero
        var defaultColor: UInt = 0
        var selectedColor: UInt = 0
        var alpha: CGFloat = 1
        
//        static var fieldSettingsView: FieldSettingsView = {
//           let view = FieldSettingsView(model: <#T##Binding<Popover.FieldSettings>#>)
//        }()
    }
}
