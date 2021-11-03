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
                    IconButton(activeTab: $tabViewModel.activeTab, tabType: .photos)
                    CameraButton(activeTab: $tabViewModel.activeTab)
                    IconButton(activeTab: $tabViewModel.activeTab, tabType: .lists)
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
                    .opacity(tabViewModel.activeTab == .camera ? 1 : 0)
                    .offset(x: 0, y: tabViewModel.activeTab == .camera ? 0 : -40)
            )
        
            .padding(EdgeInsets(top: 16, leading: 16, bottom: Constants.tabBarBottomPadding, trailing: 16))
            .background(
                Color(tabViewModel.activeTab == .camera ? Constants.tabBarDarkBackgroundColor : Constants.tabBarLightBackgroundColor)
            )
            .overlay(
                Rectangle()
                    .fill(Color(UIColor.secondaryLabel))
                    .frame(height: tabViewModel.activeTab == .camera ? 0 : 0.5)
                , alignment: .top)
            
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

struct IconButton: View {
    @Binding var activeTab: TabType
    let tabType: TabType
    
    var body: some View {
        Button {
            withAnimation {
                activeTab = tabType
            }
        } label: {
            Group {
                Image(tabType.rawValue)
                    .foregroundColor(attributes.foregroundColor)
            }
            .frame(maxWidth: .infinity)
            .frame(height: attributes.backgroundHeight)
        }
        .buttonStyle(IconButtonStyle())
    }
    
    var attributes: IconAttributes {
        if tabType == .photos {
            if activeTab == tabType {
                return IconAttributes.Photos.active
            } else if activeTab == .camera {
                return IconAttributes.Photos.inactiveDarkBackground
            } else {
                return IconAttributes.Photos.inactiveLightBackground
            }
        } else {
            if activeTab == tabType {
                return IconAttributes.Lists.active
            } else if activeTab == .camera {
                return IconAttributes.Lists.inactiveDarkBackground
            } else {
                return IconAttributes.Lists.inactiveLightBackground
            }
        }
    }
}

struct CameraButton: View {
    @Binding var activeTab: TabType
    let tabType = TabType.camera
    
    var body: some View {
        Button {
            withAnimation {
                activeTab = tabType
            }
        } label: {
            Group {
                Circle()
                    .fill(attributes.fillColor)
                    .overlay(
                        Circle()
                            .stroke(attributes.rimColor, lineWidth: attributes.rimWidth)
                    )
                    .frame(width: attributes.length, height: attributes.length)
            }
            .frame(maxWidth: .infinity)
            .frame(height: attributes.backgroundHeight)
        }
        
        .buttonStyle(CameraButtonStyle(isShutter: activeTab == tabType))
    }
    
    var attributes: CameraAttributes {
        if activeTab == tabType {
            return CameraAttributes.active
        } else {
            return CameraAttributes.inactive
        }
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
