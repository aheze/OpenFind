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
