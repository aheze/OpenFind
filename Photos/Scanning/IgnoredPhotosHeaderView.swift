//
//  IgnoredPhotosHeaderView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct IgnoredPhotosHeaderView: View {
    @ObservedObject var model: PhotosViewModel

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "info.circle.fill")
                    .font(UIFont.preferredFont(forTextStyle: .title3).font)
                    .foregroundColor(Color.accent)

                Text("Find will never scan these photos.")
                    .fixedSize(horizontal: false, vertical: true)
            }
            .foregroundColor(Color.accent)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color.accent.opacity(0.1))
            .cornerRadius(PhotosResultsCellConstants.cornerRadius)

            if model.ignoredPhotos.isEmpty {
                Text("No ignored photos.")
                    .foregroundColor(UIColor.secondaryLabel.color)
            }
        }
    }
}
