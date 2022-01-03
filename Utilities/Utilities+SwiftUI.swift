//
//  Utilities+SwiftUI.swift
//  Popover
//
//  Created by Zheng on 12/3/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

/// Position a view using a rectangular frame. Access using `.frame(rect:)`.
struct FrameRectModifier: ViewModifier {
    let rect: CGRect
    func body(content: Content) -> some View {
        content
            .frame(width: rect.width, height: rect.height, alignment: .topLeading)
            .position(x: rect.origin.x + rect.width / 2, y: rect.origin.y + rect.height / 2)
        
    }
}

public extension View {
    /// Position a view using a rectangular frame.
    func frame(with rect: CGRect) -> some View {
        return self.modifier(FrameRectModifier(rect: rect))
    }
}

/// from https://forums.swift.org/t/swiftui-extension-for-os-specific-view-modifiers-that-seems-too-arcane-to-implement/30897/13
extension View {
  @inlinable
  func modify<T: View>(@ViewBuilder modifier: ( Self ) -> T) -> T {
    return modifier(self)
  }
}

extension Shape {
    func fill<Fill: ShapeStyle, Stroke: ShapeStyle>(_ fillStyle: Fill, strokeBorder strokeStyle: Stroke, lineWidth: CGFloat = 1) -> some View {
        self
            .stroke(strokeStyle, lineWidth: lineWidth)
            .background(self.fill(fillStyle))
    }
}

extension InsettableShape {
    func fill<Fill: ShapeStyle, Stroke: ShapeStyle>(_ fillStyle: Fill, strokeBorder strokeStyle: Stroke, lineWidth: CGFloat = 1) -> some View {
        self
            .strokeBorder(strokeStyle, lineWidth: lineWidth)
            .background(self.fill(fillStyle))
    }
}
