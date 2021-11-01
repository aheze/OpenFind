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
        Color.purple.overlay(
            VStack {
                HStack(alignment: .bottom, spacing: 0) {
                    IconButton(activeTab: $tabViewModel.activeTab, tabType: .photos)
                    CameraButton(activeTab: $tabViewModel.activeTab)
                    IconButton(activeTab: $tabViewModel.activeTab, tabType: .lists)
                }
                .border(Color.black, width: 5)
                .padding(.horizontal, 16)
                .padding(.bottom, 26)
            }, alignment: .bottom
        ).edgesIgnoringSafeArea(.all)  
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
            .background(Color.green)
        }
    }
    
    var attributes: IconAttributes {
        if tabType == .photos {
            if activeTab == tabType {
                return IconAttributes.Photos.active
            } else {
                return IconAttributes.Photos.inactive
            }
        } else {
            if activeTab == tabType {
                return IconAttributes.Lists.active
            } else {
                return IconAttributes.Lists.inactive
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
            .background(Color.yellow)
        }
    }
    
    var attributes: CameraAttributes {
        if activeTab == tabType {
            return CameraAttributes.active
        } else {
            return CameraAttributes.inactive
        }
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
