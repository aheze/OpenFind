//
//  KeyboardToolbarView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/27/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct ToolbarView: View {
    @ObservedObject var model: KeyboardToolbarViewModel

    var body: some View {
        VStack {
            Text("Toolbar")
                .font(.body.bold())
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color.blue
                .edgesIgnoringSafeArea(.all)
        )
    }
}
