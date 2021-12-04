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

extension Popover {
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

/// convert to popover coordinates
extension UIView {
    func popoverOrigin(anchor: Popover.Anchor, offset: CGFloat = 8) -> Popover.Position {
        var point: CGPoint
        let frameInWindow = self.convert(self.bounds, to: nil)
        
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
        
        return Popover.Position(anchor: anchor, origin: point)
    }
}

