//
//  LaunchView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import SwiftUI

enum LaunchViewConstants {
    static var sidePadding = CGFloat(24)
    static var shadowPadding = CGFloat(48)
    
    static var headerFont = Font.system(size: 48, weight: .bold)
    static var headerTopPadding = CGFloat(48)
    
    static var footerBottomPadding = CGFloat(16)
    static var footerCornerRadius = CGFloat(20)
}

struct LaunchView: View {
    @ObservedObject var model: LaunchViewModel
    let c = LaunchViewConstants.self
    
    var body: some View {
        VStack {
            Text("Find")
                .font(c.headerFont)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(EdgeInsets(top: c.headerTopPadding, leading: c.sidePadding, bottom: c.shadowPadding, trailing: c.sidePadding))
                .background(
                    LaunchGradientView(transparentBottom: true)
                )
            
            Spacer()
            
            Button {
                print("pressed")
            } label: {
                Text("Let's Go!")
                    .font(UIFont.preferredCustomFont(forTextStyle: .title1, weight: .medium).font)
                    .frame(maxWidth: .infinity)
                    .padding(EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24))
                    .background(.white.opacity(0.1))
                    .cornerRadius(c.footerCornerRadius)
            }
            .frame(maxWidth: .infinity)
            .padding(EdgeInsets(top: c.shadowPadding, leading: c.sidePadding, bottom: c.footerBottomPadding, trailing: c.sidePadding))
            .background(
                LaunchGradientView(transparentBottom: false)
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundColor(.white)
        .opacity(model.showingUI ? 1 : 0)
    }
}

struct LaunchGradientView: View {
    var transparentBottom: Bool
    var body: some View {
        LinearGradient(
            stops: [
                .init(
                    color: Colors.accentDarkBackground.color,
                    location: 0.8
                ),
                .init(
                    color: Colors.accentDarkBackground.color.opacity(0),
                    location: 1
                )
            ],
            startPoint: transparentBottom ? .top : .bottom,
            endPoint: transparentBottom ? .bottom : .top
        )
        .edgesIgnoringSafeArea(.all)
    }
}
