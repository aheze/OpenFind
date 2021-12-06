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
//    func popoverPoint(anchor: PopoverContext.Position.Anchor) {
//        
//    }
//    func popoverOrigin(anchor: PopoverContext.Anchor, offset: CGFloat = 8) -> PopoverContext.Position {
//        var point: CGPoint
//        let frameInWindow = windowFrame()
//
//        switch anchor {
//        case .topLeft:
//            point = CGPoint(x: frameInWindow.minX, y: frameInWindow.minY - offset)
//        case .topRight:
//            point = CGPoint(x: frameInWindow.maxX, y: frameInWindow.minY - offset)
//        case .bottomLeft:
//            point = CGPoint(x: frameInWindow.minX, y: frameInWindow.maxY + offset)
//        case .bottomRight:
//            point = CGPoint(x: frameInWindow.maxX, y: frameInWindow.maxY + offset)
//        }
//
//        return .init(anchor: anchor, origin: point)
//    }
    
    /// frame in the global window
    func windowFrame() -> CGRect {
        return self.convert(bounds, to: nil)
    }
    func popoverOriginFrame() -> (() -> CGRect) {
        return {
            self.windowFrame()
        }
    }
}

//extension PopoverContext.Position.Anchor {
//
//
//
//    func getPoint() {
//        switch context.position.anchor {
//        case .topLeft:
//            return CGRect(
//                origin: context.position.point,
//                size: context.size
//            )
//        case .top:
//            return CGRect(
//                origin: context.position.point - CGPoint(x: context.size.width / 2, y: 0),
//                size: context.size
//            )
//        case .topRight:
//            return CGRect(
//                origin: context.position.point - CGPoint(x: context.size.width, y: 0),
//                size: context.size
//            )
//        case .right:
//            return CGRect(
//                origin: context.position.point - CGPoint(x: context.size.width, y: context.size.height / 2),
//                size: context.size
//            )
//        case .bottomRight:
//            return CGRect(
//                origin: context.position.point - CGPoint(x: context.size.width, y: context.size.height),
//                size: context.size
//            )
//        case .bottom:
//            return CGRect(
//                origin: context.position.point - CGPoint(x: context.size.width / 2, y: context.size.height),
//                size: context.size
//            )
//        case .bottomLeft:
//            return CGRect(
//                origin: context.position.point - CGPoint(x: 0, y: context.size.height),
//                size: context.size
//            )
//        case .left:
//            return CGRect(
//                origin: context.position.point - CGPoint(x: 0, y: context.size.height / 2),
//                size: context.size
//            )
//        }
//    }
//}
