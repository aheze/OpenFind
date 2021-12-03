//
//  TabBarView.swift
//  TabBarController
//
//  Created by Zheng on 10/30/21.
//

import SwiftUI

/// `CameraToolbarView` is passed in from `CameraViewController`
struct TabBarView<CameraToolbarView: View, PhotosSelectionToolbarView: View, PhotosDetailToolbarView: View, ListsSelectionToolbarView: View>: View {
    @ObservedObject var tabViewModel: TabViewModel
    @ObservedObject var toolbarViewModel: ToolbarViewModel
    @ObservedObject var cameraViewModel: CameraViewModel
    
    @ViewBuilder var cameraToolbarView: CameraToolbarView
    
    @ViewBuilder var photosSelectionToolbarView: PhotosSelectionToolbarView
    @ViewBuilder var photosDetailToolbarView: PhotosDetailToolbarView
    @ViewBuilder var listsSelectionToolbarView: ListsSelectionToolbarView
    
    var body: some View {
        Color.clear
            .overlay(
                HStack(alignment: .bottom, spacing: 0) {
                    PhotosButton(tabViewModel: tabViewModel, attributes: tabViewModel.photosIconAttributes)
                    CameraButton(tabViewModel: tabViewModel, attributes: tabViewModel.cameraIconAttributes)
                    ListsButton(tabViewModel: tabViewModel, attributes: tabViewModel.listsIconAttributes)
                }
                    .padding(.bottom, ConstantVars.tabBarOverflowingIconsBottomPadding)
                    .opacity(toolbarViewModel.toolbar == .none ? 1 : 0)
                    .overlay(
                        VStack {
                            switch toolbarViewModel.toolbar {
                            case .none:
                                EmptyView()
                            case .photosSelection:
                                photosSelectionToolbarView
                            case .photosDetail:
                                photosDetailToolbarView
                            case .listsSelection:
                                listsSelectionToolbarView
                            }
                        }
                            .frame(maxHeight: .infinity)
                            .padding(.bottom, ConstantVars.tabBarHuggingBottomPadding)
                    )
                    .overlay(
                        cameraToolbarView
                            .opacity(tabViewModel.tabBarAttributes.toolbarAlpha)
                            .offset(x: 0, y: tabViewModel.tabBarAttributes.toolbarOffset)
                    )
                    .frame(height: tabViewModel.tabBarAttributes.backgroundHeight, alignment: .bottom)
                    .padding(.horizontal, 16)
                
                /// right after this point is the area of visual tab bar background (what the user sees)
                
                    .background(BackgroundView(tabViewModel: tabViewModel))
                
                , alignment: .bottom
            )
            .edgesIgnoringSafeArea(.all)
    }
}

struct BackgroundView: View {
    @ObservedObject var tabViewModel: TabViewModel
    
    var body: some View {
        ZStack {
            if Debug.tabBarAlwaysTransparent == false {
                VisualEffectView(progress: $tabViewModel.animatorProgress)
            }
            tabViewModel.tabBarAttributes.backgroundColor.color.opacity(0.5)
        }
        .border( /// border is less glitchy than overlay
            Color(UIColor.secondaryLabel)
                .opacity(tabViewModel.tabBarAttributes.topLineAlpha),
            width: 0.5
        )
    }
}
struct PhotosButton: View {
    let tabType = TabState.photos
    @ObservedObject var tabViewModel: TabViewModel
    let attributes: PhotosIconAttributes
    
    var body: some View {
        IconButton(tabType: tabType, tabViewModel: tabViewModel) {
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
    @ObservedObject var tabViewModel: TabViewModel
    let attributes: CameraIconAttributes
    
    var body: some View {
        Button {
            tabViewModel.changeTabState(newTab: tabType, animation: .clickedTabIcon)
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
        .buttonStyle(CameraButtonStyle(isShutter: tabViewModel.tabState == tabType))
    }
}

struct ListsButton: View {
    let tabType = TabState.lists
    @ObservedObject var tabViewModel: TabViewModel
    let attributes: ListsIconAttributes
    
    var body: some View {
        IconButton(tabType: tabType, tabViewModel: tabViewModel) {
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
