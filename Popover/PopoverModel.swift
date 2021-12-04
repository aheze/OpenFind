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
//    @Published var fieldSettings: Popover.FieldSettings?
    @Published var popovers = [Popover]()
}

enum Popover: Identifiable {
    var id: UUID {
        switch self {
        case .fieldSettings(let configuration):
            return configuration.popoverContext.id
        }
    }
    var frame: CGRect {
        switch self {
        case .fieldSettings(let configuration):
            return CGRect(
                origin: configuration.popoverContext.wrappedValue.origin,
                size: configuration.popoverContext.wrappedValue.size
            )
        }
    }
    case fieldSettings(Binding<PopoverConfiguration.FieldSettings>)
}
struct PopoverConfiguration {
    struct FieldSettings {
        var popoverContext = PopoverContext()
        
        var defaultColor: UInt = 0
        var selectedColor: UInt = 0
        var alpha: CGFloat = 1
    }
}
//}
//protocol Popover: Identifiable {
//
//}
struct PopoverContext: Identifiable {
    let id = UUID()
    
    /// position of the popover
    var origin: CGPoint = .zero
    
    /// calculated from SwiftUI
    var size: CGSize = .zero
    
    /// if click in once of these rects, don't dismiss the popover. Otherwise, dismiss.
    var keepPresentedRects: [CGRect] = []
}
