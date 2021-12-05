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
    
    static func present(_ popover: Popover, animation: Animation? = nil) {
        withAnimation(animation) {
            Popovers.model.popovers.append(popover)
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

class PopoverState: ObservableObject {
    
}
struct PopoverContext: Identifiable {
    var id = UUID()
    
    /// position of the popover
    var position: Position = .init(anchor: .bottomLeft, origin: .zero)
    
    /// calculated from SwiftUI
    var size: CGSize = .zero
    
    /// if click in once of these rects, don't dismiss the popover. Otherwise, dismiss.
    var dismissMode: DismissMode = .tapOutside(.init())
    
    
    enum DismissMode {
        case tapOutside(DismissContext)
        case none
    }
    struct DismissContext {
        var animation: Animation?
        var excludedRects = [CGRect]()
    }
    
    enum Anchor {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
    }
    
    struct Position {
        var anchor: Anchor
        var origin: CGPoint
    }
    
}

//enum Popover: Identifiable, Equatable {
struct Popover: Identifiable, Equatable {
    
    var context = PopoverContext()
    var view: AnyView
    
    static func == (lhs: Popover, rhs: Popover) -> Bool {
        lhs.id == rhs.id
    }
    
    var id: UUID {
        return context.id
    }
    
    var frame: CGRect {
        switch context.position.anchor {
        case .topLeft:
            return CGRect(origin: context.position.origin - CGPoint(x: 0, y: context.size.height), size: context.size)
        case .topRight:
            return CGRect(origin: context.position.origin - CGPoint(x: 0, y: context.size.height), size: context.size)
        case .bottomLeft:
            return CGRect(origin: context.position.origin, size: context.size)
        case .bottomRight:
            return CGRect(origin: context.position.origin, size: context.size)
        }
    }
    
    var keepPresentedRects: [CGRect] {
        if case let .tapOutside(dismissContext) = context.dismissMode {
            return dismissContext.excludedRects
        }
        return []
    }
    
}





