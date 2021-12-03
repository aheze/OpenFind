//
//  IconButtons.swift
//  TabController
//
//  Created by Zheng on 12/2/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

struct PhotosButton: View {
    let tabType = TabState.photos
    @ObservedObject var tabViewModel: TabViewModel
    let attributes: PhotosIconAttributes
    
    var body: some View {
        TabButton(tabType: tabType, tabViewModel: tabViewModel) {
            Group {
                Image(tabType.name)
                    .foregroundColor(attributes.foregroundColor.color)
            }
            .frame(maxWidth: .infinity)
            .frame(height: attributes.backgroundHeight)
        }
    }
}

struct ListsButton: View {
    let tabType = TabState.lists
    @ObservedObject var tabViewModel: TabViewModel
    let attributes: ListsIconAttributes
    
    var body: some View {
        TabButton(tabType: tabType, tabViewModel: tabViewModel) {
            Group {
                Image(tabType.name)
                    .foregroundColor(attributes.foregroundColor.color)
            }
            .frame(maxWidth: .infinity)
            .frame(height: attributes.backgroundHeight)
        }
    }
}


struct TabButton<Content: View>: View {
    let tabType: TabState
    @ObservedObject var tabViewModel: TabViewModel
    @ViewBuilder var content: Content
    
    var body: some View {
        Button {
            tabViewModel.changeTabState(newTab: tabType, animation: .clickedTabIcon)
        } label: {
            content
        }
        .buttonStyle(IconButtonStyle())
    }
}


struct IconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .modifier(FadingButtonModifier(isPressed: configuration.isPressed))
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct FadingButtonModifier: ViewModifier {
    let isPressed: Bool
    func body(content: Content) -> some View {
        content
            .opacity(isPressed ? 0.5 : 1)
    }
}
