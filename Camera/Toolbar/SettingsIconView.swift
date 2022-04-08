//
//  OpenSettingsIconView.swift
//  TabBarControllerTesting
//
//  Created by Zheng on 11/11/21.
//

import SwiftUI

struct OpenSettingsIconView: View {
    @ObservedObject var model: CameraViewModel
    @State var scaleAnimationActive = false
    
    var body: some View {
        Button {
            /// small scale animation
            withAnimation(.spring()) { scaleAnimationActive = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.toolbarIconDeactivateAnimationDelay) {
                withAnimation(.easeOut(duration: Constants.toolbarIconDeactivateAnimationSpeed)) { scaleAnimationActive = false }
            }
            
            model.settingsPressed?()
        } label: {
            Image(systemName: "gearshape.fill")
                .scaleEffect(scaleAnimationActive ? 1.2 : 1)
                .frame(width: 40, height: 40)
                .foregroundColor(.white)
                .font(.system(size: 19))
                .cameraToolbarIconBackground(toolbarState: model.toolbarState)
        }
    }
}
