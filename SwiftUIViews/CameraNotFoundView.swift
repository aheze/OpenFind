//
//  CameraNotFoundView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/13/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct CameraNotFoundView: View {
    @ObservedObject var tabViewModel: TabViewModel
    var body: some View {
        LinearGradient(
            colors: [
                Color(hex: 0x00AEEF),
                Color(hex: 0x0070AF)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            VStack(alignment: .leading, spacing: 16) {
                Text("No Camera Found")
                    .font(.title.bold())

                Text("Find was not able to access the camera. Would you like to find from your photos instead?")
                    .fontWeight(.medium)

                Button {
                    tabViewModel.changeTabState(newTab: .photos, animation: .animate)
                } label: {
                    Text("Find From Photos")
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                        .background(Color.white.opacity(0.25))
                        .cornerRadius(12)
                }
            }
            .foregroundColor(.white)
            .padding(24)
            .background(Color.black.opacity(0.2))
            .cornerRadius(20)
            .padding(36)
            .frame(maxWidth: 500, maxHeight: .infinity)
        )
        .edgesIgnoringSafeArea(.all)
    }
}
