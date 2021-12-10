//
//  PopoverReader.swift
//  Popover
//
//  Created by Zheng on 12/9/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

//struct PopoverReader<Content: View>: View {
//    
//    @ViewBuilder var content: (Popover.Context) -> Content
////    @EnvironmentObject var context: Popover.Context
//
//    var body: some View {
//        content(context)
//    }
//}

struct CustomGeometryReaderView<Content: View>: View {

    @ViewBuilder let content: (CGSize) -> Content

    private struct AreaReader: Shape {
        @Binding var size: CGSize

        func path(in rect: CGRect) -> Path {
            DispatchQueue.main.async {
                size = rect.size
            }
            return Rectangle().path(in: rect)
        }
    }

    @State private var size = CGSize.zero

    var body: some View {
        // by default shape is black so we need to clear it explicitly
        AreaReader(size: $size).foregroundColor(.clear)
            .overlay(Group {
                if size != .zero {
                    content(size)
                }
            })
    }
}
