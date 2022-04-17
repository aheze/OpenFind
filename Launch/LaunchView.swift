//
//  LaunchView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

enum LaunchViewConstants {
    static var spacing = CGFloat(16)
    
    static var sidePadding = CGFloat(24)
    static var shadowPadding = CGFloat(54)

    static var headerSpacing = CGFloat(8)
    static var headerTitleFont = UIFont.systemFont(ofSize: 48, weight: .bold)
    static var headerSubtitleFont = UIFont.systemFont(ofSize: 24, weight: .medium)
    static var headerTopPadding = CGFloat(48)

    static var footerBottomPadding = CGFloat(16)
    static var footerCornerRadius = CGFloat(20)

    static var controlButtonFont = UIFont.preferredFont(forTextStyle: .title3)
}

struct LaunchView: View {
    @ObservedObject var model: LaunchViewModel
    let c = LaunchViewConstants.self

    var body: some View {
        VStack(spacing: c.spacing) {
            VStack(spacing: c.headerSpacing) {
                Text("Find")
                    .font(c.headerTitleFont.font)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("An app to find text in real life.")
                    .font(c.headerSubtitleFont.font)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(EdgeInsets(top: c.headerTopPadding, leading: c.sidePadding, bottom: c.shadowPadding, trailing: c.sidePadding))
            .background(
                LaunchGradientView(transparentBottom: true)
            )
            .opacity(model.currentPage == .empty ? 1 : 0)
            .frame(height: model.currentPage == .empty ? nil : 0, alignment: .top)

            if model.currentPage != .empty, let currentIndex = model.getCurrentIndex() {
                let previousPage = model.pages[safe: currentIndex - 1]
                let nextPage = model.pages[safe: currentIndex + 1]
                
                HStack {
                    LaunchControlButtonView(icon: "chevron.backward") {
                        if let previousPage = previousPage {
                            model.setCurrentPage(to: previousPage)
                        }
                    }
                    
                    Spacer()
                    
                    LaunchControlButtonView(icon: "chevron.forward") {
                        if let nextPage = nextPage {
                            model.setCurrentPage(to: nextPage)
                        }
                    }
                    .opacity(nextPage != nil ? 1 : 0)
                }
                .padding(.horizontal, c.sidePadding)
            }

            LaunchContentView(model: model)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            Button {
                withAnimation {
                    model.setCurrentPage(to: .photos)
                }
            } label: {
                Text("Let's Go!")
                    .font(UIFont.preferredCustomFont(forTextStyle: .title1, weight: .medium).font)
                    .frame(maxWidth: .infinity)
                    .padding(EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24))
                    .background(.white.opacity(0.1))
                    .cornerRadius(c.footerCornerRadius)
            }
            .buttonStyle(LaunchButtonStyle())
            .frame(maxWidth: .infinity)
            .padding(EdgeInsets(top: c.shadowPadding, leading: c.sidePadding, bottom: c.footerBottomPadding, trailing: c.sidePadding))
            .background(
                LaunchGradientView(transparentBottom: false)
            )
            .opacity(model.currentPage == .empty ? 1 : 0)
            .frame(height: model.currentPage == .empty ? nil : 0, alignment: .bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundColor(.white)
        .opacity(model.showingUI ? 1 : 0)
    }
}

struct LaunchControlButtonView: View {
    var icon: String
    var action: () -> Void

    let c = LaunchViewConstants.self

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .foregroundColor(.white)
                .font(c.controlButtonFont.font)
                .padding(12)
                .background(
                    Circle()
                        .fill(.white.opacity(0.15))
                )
        }
        .buttonStyle(LaunchButtonStyle())
    }
}

struct LaunchContentView: UIViewControllerRepresentable {
    @ObservedObject var model: LaunchViewModel

    func makeUIViewController(context: Context) -> LaunchContentViewController {
        LaunchContentViewController.make(model: model)
    }

    func updateUIViewController(_ uiViewController: LaunchContentViewController, context: Context) {}
}

struct LaunchButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(
                .spring(
                    response: 0.2,
                    dampingFraction: 0.4,
                    blendDuration: 1
                ),
                value: configuration.isPressed
            )
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
