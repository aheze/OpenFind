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
    var sizeChanged: ((CGSize) -> Void)?
    var body: some View {
        PhotosTextOverlayView(model: model)
            .sizeReader {
                sizeChanged?($0)
            }
    }
}
