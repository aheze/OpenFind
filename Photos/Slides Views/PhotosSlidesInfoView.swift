//
//  PhotosSlidesInfoView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct PhotosSlidesInfoView: View {
    @ObservedObject var model: PhotosViewModel
    var body: some View {
        Button {
            print("Hi!")
        } label: {
            Text("Hello!")
                .padding()
        }
        .foregroundColor(.accent)
        .frame(maxWidth: .infinity)
    }
}
 
