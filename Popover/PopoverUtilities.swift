//
//  PopoverUtilities.swift
//  Popover
//
//  Created by Zheng on 12/3/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

/// https://stackoverflow.com/a/59733037/14351818
struct GeometrySizeWriter: View {
    @Binding var size: CGSize?

    var body: some View {
        GeometryReader { proxy -> Color in
            
            /// prevent infinite loop
            if self.size != proxy.size {
                DispatchQueue.main.async {
                    self.size = proxy.size
                }
            }
            return Color.clear
        }
    }
}

extension View {
    func writeSize(to size: Binding<CGSize?>) -> some View {
        return self.background(GeometrySizeWriter(size: size))
    }
    func frame(rect: CGRect) -> some View {
        return self.modifier(FrameRect(rect: rect))
    }
}

struct FrameRect: ViewModifier {
    let rect: CGRect
    func body(content: Content) -> some View {
        content
//            .position(x: rect.origin.x, y: rect.origin.y)
//            .frame(width: 50, height: 50)
            .position(x: rect.origin.x + rect.width / 2, y: rect.origin.y + rect.height / 2)
            .frame(width: rect.width, height: rect.height, alignment: .topLeading)
    }
}

/// convert to popover coordinates
extension UIView {
    /// frame in the global window
    func windowFrame() -> CGRect {
        return self.convert(bounds, to: nil)
    }
    func popoverOriginFrame() -> (() -> CGRect) {
        
        /// return a closure that gets the frame of the view
        /// it's a closure because view frames can change
        return {
            self.windowFrame()
        }
    }
}

extension CGRect {
    func pointAtAnchor(_ anchor: Popover.Position.Anchor) -> CGPoint {
        switch anchor {
        case .topLeft:
            return self.origin
        case .top:
            return CGPoint(
                x: self.origin.x + self.width / 2,
                y: self.origin.y
            )
        case .topRight:
            return CGPoint(
                x: self.origin.x + self.width,
                y: self.origin.y
            )
        case .right:
            return CGPoint(
                x: self.origin.x + self.width,
                y: self.origin.y + self.height / 2
            )
        case .bottomRight:
            return CGPoint(
                x: self.origin.x + self.width,
                y: self.origin.y + self.height
            )
        case .bottom:
            return CGPoint(
                x: self.origin.x + self.width / 2,
                y: self.origin.y + self.height
            )
        case .bottomLeft:
            return CGPoint(
                x: self.origin.x,
                y: self.origin.y + self.height
            )
        case .left:
            return CGPoint(
                x: self.origin.x + self.width,
                y: self.origin.y + self.height / 2
            )
        }
    }
}
