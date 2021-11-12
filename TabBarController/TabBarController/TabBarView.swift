//
//  TabBarView.swift
//  TabBarController
//
//  Created by Zheng on 10/30/21.
//

import SwiftUI

/// `CameraToolbarView` is passed in from `CameraViewController`
struct TabBarView<ToolbarViewModel: ObservableObject, CameraToolbarView: View>: View {
    @ObservedObject var tabViewModel: TabViewModel
    @ObservedObject var toolbarViewModel: ToolbarViewModel
    @ViewBuilder var cameraToolbarView: CameraToolbarView
    
    var body: some View {
        Color.clear.overlay(
            VStack {
                HStack(alignment: .bottom, spacing: 0) {
                    PhotosButton(tabState: $tabViewModel.tabState, attributes: tabViewModel.photosIconAttributes)
                    CameraButton(tabState: $tabViewModel.tabState, attributes: tabViewModel.cameraIconAttributes)
                    ListsButton(tabState: $tabViewModel.tabState, attributes: tabViewModel.listsIconAttributes)
                }
            }
                .overlay(
                        cameraToolbarView
                        .opacity(tabViewModel.tabBarAttributes.toolbarAlpha)
                        .offset(x: 0, y: tabViewModel.tabBarAttributes.toolbarOffset)
                )
                .padding(EdgeInsets(top: 16, leading: 16, bottom: Constants.tabBarBottomPadding, trailing: 16))
                .background(
                    ZStack {
                        VisualEffectView(progress: $tabViewModel.animatorProgress)
                        tabViewModel.tabBarAttributes.backgroundColor.color.opacity(0.5)
                    }
                )
                .border(Color(UIColor.secondaryLabel).opacity(tabViewModel.tabBarAttributes.topLineAlpha), width: 0.5) /// border is less glitchy than overlay
            
            , alignment: .bottom
        )
        .edgesIgnoringSafeArea(.all)
    }
}

struct BackgroundView: View {
    @ObservedObject var tabViewModel: TabViewModel
    
    var body: some View {
        ZStack {
            VisualEffectView(progress: $tabViewModel.animatorProgress)
            tabViewModel.tabBarAttributes.backgroundColor.color.opacity(0.5)
        }
        .border( /// border is less glitchy than overlay
            Color(UIColor.secondaryLabel)
                .opacity(tabViewModel.tabBarAttributes.topLineAlpha),
            width: 0.5
        )
    }
}
//struct BackgroundView: ViewModifier {
//    @ObservedObject var tabViewModel: TabViewModel
//
//    func body(content: Content) -> some View {
//        content.background(
//            ZStack {
//                VisualEffectView(progress: $tabViewModel.animatorProgress)
//                tabViewModel.tabBarAttributes.backgroundColor.color.opacity(0.5)
//            }
//        )
//            .border( /// border is less glitchy than overlay
//                Color(UIColor.secondaryLabel)
//                    .opacity(tabViewModel.tabBarAttributes.topLineAlpha),
//                width: 0.5
//            )
//    }
//}

struct PhotosButton: View {
    let tabType = TabState.photos
    @Binding var tabState: TabState
    let attributes: PhotosIconAttributes
    
    var body: some View {
        IconButton(tabType: tabType, tabState: $tabState) {
            Group {
                Image(tabType.name)
                    .foregroundColor(attributes.foregroundColor.color)
            }
            .frame(maxWidth: .infinity)
            .frame(height: attributes.backgroundHeight)
        }
    }
}

struct CameraButton: View {
    let tabType = TabState.camera
    @Binding var tabState: TabState
    let attributes: CameraIconAttributes
    
    var body: some View {
        Button {
            withAnimation {
                tabState = tabType
            }
        } label: {
            Group {
                Circle()
                    .fill(attributes.foregroundColor.color)
                    .overlay(
                        Circle()
                            .stroke(attributes.rimColor.color, lineWidth: attributes.rimWidth)
                    )
                    .frame(width: attributes.length, height: attributes.length)
            }
            .frame(maxWidth: .infinity)
            .frame(height: attributes.backgroundHeight)
        }
        
        .buttonStyle(CameraButtonStyle(isShutter: tabState == tabType))
    }
}

struct ListsButton: View {
    let tabType = TabState.lists
    @Binding var tabState: TabState
    let attributes: ListsIconAttributes
    
    var body: some View {
        IconButton(tabType: tabType, tabState: $tabState) {
            Group {
                Image(tabType.name)
                    .foregroundColor(attributes.foregroundColor.color)
            }
            .frame(maxWidth: .infinity)
            .frame(height: attributes.backgroundHeight)
        }
    }
}


struct IconButton<Content: View>: View {
    let tabType: TabState
    @Binding var tabState: TabState
    @ViewBuilder var content: Content
    
    var body: some View {
        Button {
            withAnimation {
                tabState = tabType
            }
        } label: {
            content
        }
        .buttonStyle(IconButtonStyle())
    }
}


struct CameraButtonStyle: ButtonStyle {
    var isShutter: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect((isShutter && configuration.isPressed) ? 0.9 : 1)
            .modifier(FadingButtonModifier(isPressed: !isShutter && configuration.isPressed))
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
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


//struct TabBarView_Previews: PreviewProvider {
//    static var previews: some View {
//        TabBarView(tabViewModel: TabViewModel(), toolbarViewModel: <#_#>) {
//            Color.clear
//        }
//    }
//}
