//
//  Toolbar.swift
//  TabBarController
//
//  Created by Zheng on 11/12/21.
//

import SwiftUI

class ToolbarViewModel: ObservableObject {
    @Published var toolbar: AnyView? = nil
    
    var didDismiss: (() -> Void)?
}

struct ToolbarIconButton: View {
    var iconName: String
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: iconName)
                .font(Font(Constants.iconFont))
        }
    }
}
