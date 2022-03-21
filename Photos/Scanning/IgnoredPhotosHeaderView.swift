//
//  IgnoredPhotosHeaderView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

class IgnoredPhotosHeaderViewModel: ObservableObject {
    @Published var show = false
}

struct IgnoredPhotosHeaderView: View {
    @ObservedObject var model: PhotosViewModel
    @ObservedObject var ignoredPhotosHeaderViewModel: IgnoredPhotosHeaderViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Image(systemName: "info")
            Text("Find will never scan these photos")
        }
        .foregroundColor(Color.accent)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(PhotosScanningConstants.padding)
        .background(Color.accent.opacity(0.1))
        .cornerRadius(PhotosResultsCellConstants.cornerRadius)
    }
}
