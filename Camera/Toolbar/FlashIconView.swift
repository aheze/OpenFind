//
//  FlashIconView.swift
//  TabBarControllerTesting
//
//  Created by Zheng on 11/10/21.
//

import SwiftUI

struct FlashIconView: View {
    @ObservedObject var model: CameraViewModel
    var isEnabled: Bool
    
    @State var scaleAnimationActive = false

    var body: some View {
        Button {
            scale(scaleAnimationActive: $scaleAnimationActive)
            toggle()
        } label: {
            Image(systemName: "bolt.fill")
                .frame(width: 40, height: 40)
                .foregroundColor(model.flash ? Color(Constants.activeIconColor) : .white)
                .font(.system(size: 19))
                .enabledModifier(isEnabled: isEnabled, linePadding: 13)
                .scaleEffect(scaleAnimationActive ? 1.2 : 1)
                .cameraToolbarIconBackground(toolbarState: model.toolbarState)
        }
        .disabled(!isEnabled)
    }

    func toggle() {
        withAnimation {
            model.flash.toggle()
            model.flashPressed?()
        }
    }
}
