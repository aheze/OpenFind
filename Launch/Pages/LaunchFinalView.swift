//
//  LaunchFinalView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/17/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import SwiftUI

struct LaunchFinalView: View {
    @ObservedObject var model: LaunchViewModel
    
    let c = LaunchViewConstants.self
    
    var body: some View {
        VStack(spacing: 20) {
            Image("Logo")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 90, height: 90)
                .cornerRadius(22)
                .shadow(
                    color: Colors.accent.toColor(.black, percentage: 0.5).color.opacity(0.25),
                    radius: 3,
                    x: 0,
                    y: 2
                )
            
            Text("What will you do with Find?")
                .opacity(0.75)
                .font(UIFont.preferredCustomFont(forTextStyle: .title1, weight: .medium).font)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
            
            Button {
                model.enter?()
            } label: {
                Text("Start Finding")
                    .font(UIFont.preferredCustomFont(forTextStyle: .title1, weight: .medium).font)
                    .frame(maxWidth: .infinity)
                    .padding(EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24))
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(c.footerCornerRadius)
            }
        }
        .foregroundColor(.white)
        .padding(.top, 32)
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .background(
            LinearGradient(
                colors: [
                    UIColor(hex: 0x00AEEF).toColor(.black, percentage: 0.25).color,
                    Colors.accent.toColor(.black, percentage: 0.5).color
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(28)
        .shadow(
            color: Colors.accent.toColor(.black, percentage: 0.5).color.opacity(0.5),
            radius: 10,
            x: 0,
            y: 3
        )
        .padding(c.sidePadding)
        .offset(x: 0, y: model.showingUI ? 0 : 600)
    }
}
