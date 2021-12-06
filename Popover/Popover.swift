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
        let popoverFrame = attributes.position.popoverFrame(popoverSize: context.size)
        return popoverFrame
    }
    
    static func == (lhs: Popover, rhs: Popover) -> Bool {
        lhs.id == rhs.id
    }
    
    struct Attributes {
        var position = Position.absolute(.init())
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
    
    enum Position {
        
        case absolute(Absolute)
        case relative(Relative)
        
        struct Absolute {
            var originFrame: (() -> CGRect) = { .zero }
            
            /// the side of the origin view which the popover is attached to
            var originAnchor = Anchor.bottomLeft
            
            /// the side of the popover that gets attached to the origin
            var popoverAnchor = Anchor.topLeft
        }
        
        struct Relative {
            var popoverAnchor = Anchor.bottomLeft
        }
        
        
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
        
        func popoverFrame(popoverSize: CGSize) -> CGRect {
            let popoverOrigin = popoverOrigin(popoverSize: popoverSize)
            let popoverAnchor: Anchor
            
            switch self {
            case .absolute(let position):
                popoverAnchor = position.popoverAnchor
            case .relative(let position):
                popoverAnchor = .topLeft /// use top left as origin
            }
            
            switch popoverAnchor {
            case .topLeft:
                return CGRect(
                    origin: popoverOrigin,
                    size: popoverSize
                )
            case .top:
                return CGRect(
                    origin: popoverOrigin - CGPoint(x: popoverSize.width / 2, y: 0),
                    size: popoverSize
                )
            case .topRight:
                return CGRect(
                    origin: popoverOrigin - CGPoint(x: popoverSize.width, y: 0),
                    size: popoverSize
                )
            case .right:
                return CGRect(
                    origin: popoverOrigin - CGPoint(x: popoverSize.width, y: popoverSize.height / 2),
                    size: popoverSize
                )
            case .bottomRight:
                return CGRect(
                    origin: popoverOrigin - CGPoint(x: popoverSize.width, y: popoverSize.height),
                    size: popoverSize
                )
            case .bottom:
                return CGRect(
                    origin: popoverOrigin - CGPoint(x: popoverSize.width / 2, y: popoverSize.height),
                    size: popoverSize
                )
            case .bottomLeft:
                return CGRect(
                    origin: popoverOrigin - CGPoint(x: 0, y: popoverSize.height),
                    size: popoverSize
                )
            case .left:
                return CGRect(
                    origin: popoverOrigin - CGPoint(x: 0, y: popoverSize.height / 2),
                    size: popoverSize
                )
            }
        }
        
        /// get the popover's origin point
        /// `popoverSize` is only used for relative positioning
        func popoverOrigin(popoverSize: CGSize) -> CGPoint {
            switch self {
            case .absolute(let position):
                let originFrame = position.originFrame()
                switch position.originAnchor {
                case .topLeft:
                    return originFrame.origin
                case .top:
                    return CGPoint(
                        x: originFrame.origin.x + originFrame.width / 2,
                        y: originFrame.origin.y
                    )
                case .topRight:
                    return CGPoint(
                        x: originFrame.origin.x + originFrame.width,
                        y: originFrame.origin.y
                    )
                case .right:
                    return CGPoint(
                        x: originFrame.origin.x + originFrame.width,
                        y: originFrame.origin.y + originFrame.height / 2
                    )
                case .bottomRight:
                    return CGPoint(
                        x: originFrame.origin.x + originFrame.width,
                        y: originFrame.origin.y + originFrame.height
                    )
                case .bottom:
                    return CGPoint(
                        x: originFrame.origin.x + originFrame.width / 2,
                        y: originFrame.origin.y + originFrame.height
                    )
                case .bottomLeft:
                    return CGPoint(
                        x: originFrame.origin.x,
                        y: originFrame.origin.y + originFrame.height
                    )
                case .left:
                    return CGPoint(
                        x: originFrame.origin.x + originFrame.width,
                        y: originFrame.origin.y + originFrame.height / 2
                    )
                }
            case .relative(let position):
                let safeArea = Popovers.model.safeArea ?? UIScreen.main.bounds

                switch position.popoverAnchor {
                case .topLeft:
                    return CGPoint(
                        x: 0,
                        y: 0
                    )
                case .top:
                    return CGPoint(
                        x: safeArea.width / 2 - popoverSize.width / 2,
                        y: 0
                    )
                case .topRight:
                    return CGPoint(
                        x: safeArea.width - popoverSize.width / 2,
                        y: 0
                    )
                case .right:
                    return CGPoint(
                        x: safeArea.width - popoverSize.width / 2,
                        y: safeArea.height / 2 - popoverSize.height / 2
                    )
                case .bottomRight:
                    return CGPoint(
                        x: safeArea.width - popoverSize.width / 2,
                        y: safeArea.height - popoverSize.height / 2
                    )
                case .bottom:
                    return CGPoint(
                        x: safeArea.width / 2 - popoverSize.width / 2,
                        y: safeArea.height - popoverSize.height / 2
                    )
                case .bottomLeft:
                    return CGPoint(
                        x: 0,
                        y: safeArea.height - popoverSize.height / 2
                    )
                case .left:
                    return CGPoint(
                        x: safeArea.width - popoverSize.width / 2,
                        y: safeArea.height / 2 - popoverSize.height / 2
                    )
                }
            }
            
            
//            let normalizedOriginFrame: CGRect
//            switch originFrame {
//            case .absolute(let rect):
//                normalizedOriginFrame = rect
//            case .relative(let rect):
//                let safeArea = Popovers.model.safeArea ?? UIScreen.main.bounds
//                let scaledRect = CGRect(
//                    x: rect.origin.x * safeArea.width,
//                    y: rect.origin.y * safeArea.height,
//                    width: rect.width * safeArea.width,
//                    height: rect.height * safeArea.height
//                )
//                normalizedOriginFrame = scaledRect
//            }
            
            
            
            
        }
    }
}




