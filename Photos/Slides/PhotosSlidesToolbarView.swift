//
//  PhotosSlidesToolbarView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/18/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct PhotosSlidesToolbarView: View {
    @ObservedObject var model: PhotosViewModel

    var body: some View {
        HStack {
            ToolbarIconButton(iconName: "square.and.arrow.up") {}
        
            Spacer()
        
            ToolbarIconButton(iconName: "star") {}
        
            Spacer()
        
            ToolbarIconButton(iconName: "info.circle") {}
        
            Spacer()
        
            ToolbarIconButton(iconName: "trash") {}
        }
    }
}
