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
    @Binding var size: CGSize

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
    func writeSize(to size: Binding<CGSize>) -> some View {
        return self.background(GeometrySizeWriter(size: size))
    }
}

/// convert to popover coordinates
extension UIView {
    func popoverOrigin(anchor: PopoverContext.Anchor, offset: CGFloat = 8) -> PopoverContext.Position {
        var point: CGPoint
        let frameInWindow = windowFrame()
        
        switch anchor {
        case .topLeft:
            point = CGPoint(x: frameInWindow.minX, y: frameInWindow.minY - offset)
        case .topRight:
            point = CGPoint(x: frameInWindow.maxX, y: frameInWindow.minY - offset)
        case .bottomLeft:
            point = CGPoint(x: frameInWindow.minX, y: frameInWindow.maxY + offset)
        case .bottomRight:
            point = CGPoint(x: frameInWindow.maxX, y: frameInWindow.maxY + offset)
        }
        
        return .init(anchor: anchor, origin: point)
    }
    
    /// frame in the global window
    func windowFrame() -> CGRect {
        return self.convert(bounds, to: nil)
    }
}

