//
//  TabBarView.swift
//  TabBarController
//
//  Created by Zheng on 10/30/21.
//

import SwiftUI

struct TabBarView: View {
    @ObservedObject var tabViewModel: TabViewModel
    
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
                    Group {
                        HStack(alignment: .top, spacing: 0) {
                            HStack {
                                ToolbarButton(iconName: "arrow.up.left.and.arrow.down.right")
                                Spacer()
                                ToolbarButton(iconName: "bolt.slash.fill")
                            }
                            .frame(maxWidth: .infinity)
                            
                            Color.clear
                            
                            HStack {
                                ToolbarButton(iconName: "viewfinder")
                                Spacer()
                                ToolbarButton(iconName: "gearshape.fill")
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
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
        ).edgesIgnoringSafeArea(.all)
    }
}

struct ToolbarButton: View {
    var iconName: String
    var body: some View {
        Button {
            print("Pressed")
        } label: {
            Image(systemName: iconName)
                .foregroundColor(.white)
                .font(.system(size: 19))
                .frame(width: 40, height: 40)
                .background(.white.opacity(0.15))
                .cornerRadius(20)
        }
    }
}

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

struct ContainerView<Content: View>: View {
    @ViewBuilder var content: Content
    
    var body: some View {
        content
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


/// remap `Image` to the current bundle
struct Image: View {
    
    let source: Source
    enum Source {
        case assetCatalog(String)
        case systemIcon(String)
    }
    
    init(_ name: String) { self.source = .assetCatalog(name) }
    init(systemName: String) { self.source = .systemIcon(systemName) }
    
    var body: some View {
        switch source {
        case let .assetCatalog(name):
            SwiftUI.Image(name, bundle: Bundle(identifier: "com.aheze.TabBarController"))
        case let .systemIcon(name):
            SwiftUI.Image(systemName: name)
        }
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView(tabViewModel: TabViewModel())
    }
}
