//
//  PhotosSlidesItemToolbarView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/25/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct PhotosSlidesItemToolbarView: View {
    @ObservedObject var model: PhotosViewModel
    @ObservedObject var textOverlayViewModel: PhotosTextOverlayViewModel
    
    var sizeChanged: ((CGSize) -> Void)?
    var body: some View {
        PhotosTextOverlayView(model: model, textOverlayViewModel: textOverlayViewModel)
            .sizeReader {
                sizeChanged?($0)
            }
    }
}
