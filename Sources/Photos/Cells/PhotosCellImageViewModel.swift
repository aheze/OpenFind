//
//  PhotoCellImageViewModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 5/27/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

class PhotosCellImageViewModel: ObservableObject {
    @Published var photo: Photo?
    @Published var image: UIImage? /// image loaded from PhotoKit

    @Published var show = true /// show image or hide

    @Published var showOverlay = true /// star, ignore, etc

    @Published var showSelectionOverlay = false
    @Published var selected = false
}

extension PhotosCellImageViewModel {
    func showImage(_ show: Bool) {
        self.show = show
    }

    func showOverlay(_ show: Bool, animate: Bool) {
        withAnimation(.easeOut(duration: animate ? 0.4 : 0)) {
            self.showOverlay = show
        }
    }
}
