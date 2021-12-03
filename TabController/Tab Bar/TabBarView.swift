//
//  TabBarView.swift
//  TabBarController
//
//  Created by Zheng on 10/30/21.
//

import SwiftUI

/// `CameraToolbarView` is passed in from `CameraViewController`
struct TabBarView<PhotosSelectionToolbarView: View, PhotosDetailToolbarView: View, ListsSelectionToolbarView: View>: View {
    @ObservedObject var tabViewModel: TabViewModel
    @ObservedObject var toolbarViewModel: ToolbarViewModel
    @ObservedObject var cameraViewModel: CameraViewModel
    
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
                        CameraToolbarView(viewModel: cameraViewModel)
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
