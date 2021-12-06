//
//  Popover.swift
//  Popover
//
//  Created by Zheng on 12/5/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

struct Popover: Identifiable, Equatable {
    
    /// should stay private to the popover
    var context = Context()
    
    var attributes = Attributes()
    
    var view: AnyView
    
    init<Content: View>(context: Context = .init(), attributes: Attributes = .init(), @ViewBuilder view: @escaping () -> Content) {
        self.context = context
        self.attributes = attributes
        self.view = AnyView(view())
    }
    
    var id: UUID {
        return context.id
    }
    
    var frame: CGRect {
        return CGRect(origin: context.origin, size: context.size)
    }
    
    static func == (lhs: Popover, rhs: Popover) -> Bool {
        lhs.id == rhs.id
    }
    
    struct Attributes {
        var position = Position()
        var presentation = Presentation()
        var dismissal = Dismissal()
        
        struct Presentation {
            var animation: Animation? = .default
            var transition: AnyTransition? = .opacity
        }
        struct Dismissal {
            var animation: Animation? = .default
            var transition: AnyTransition? = .opacity
            var mode = DismissMode.whenTappedOutside
            var excludedFrames: (() -> [CGRect]) = { [] }
            
            enum DismissMode {
                case whenTappedOutside
                case none
            }
        }
    }
    
    struct Context: Identifiable {
        
        /// id of the popover
        var id = UUID()
        
        /// calculated from attributes + SwiftUI resizing
        var origin: CGPoint = .zero
        
        /// calculated from SwiftUI
        var size: CGSize = .zero
        
    }
    
    struct Position {
        
        var originFrame: (() -> CGRect) = { .zero }
        
        /// the side of the origin view which the popover is attached to
        var originAnchor = Anchor.bottomLeft
        
        /// the side of the popover that gets attached to the origin
        var popoverAnchor = Anchor.topLeft
        
        
        var repositioningMode = RepositioningMode.none
        
        enum Anchor {
            case topLeft
            case top
            case topRight
            case right
            case bottomRight
            case bottom
            case bottomLeft
            case left
        }
        
        enum RepositioningMode {
            case keepOnScreen
            case none
        }
    }
}




