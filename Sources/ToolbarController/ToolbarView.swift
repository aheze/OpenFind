//
//  ToolbarView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct ToolbarView: View {
    @ObservedObject var model: ToolbarViewModel
    var body: some View {
        VStack {
            if let toolbar = model.toolbar {
                toolbar
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 16)
    }
}
