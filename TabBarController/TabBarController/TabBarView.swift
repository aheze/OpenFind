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
        VStack {
            HStack(spacing: 0) {
                PhotosButton(activeTab: $tabViewModel.activeTab)
                CameraButton(activeTab: $tabViewModel.activeTab)
                ListsButton(activeTab: $tabViewModel.activeTab)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.purple)
        .edgesIgnoringSafeArea(.all)
        
    }
}

struct PhotosButton: View {
    @Binding var activeTab: TabType
    let tabType = TabType.photos
    
    var isActive: Bool { return activeTab == tabType }
    let inactive = PhotosAttributes.Inactive()
    let active = PhotosAttributes.Active()
    
    var body: some View {
        Button {
            withAnimation {
                activeTab = tabType
            }
        } label: {
            Image("Photos")
                .foregroundColor(isActive ? active.foregroundColor : inactive.foregroundColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.yellow)
        }
    }
}

struct CameraButton: View {
    @Binding var activeTab: TabType
    let tabType = TabType.camera
    
    var isActive: Bool { return activeTab == tabType }
    let inactive = CameraAttributes.Inactive()
    let active = CameraAttributes.Active()
    
    var body: some View {
        Button {
            withAnimation {
                activeTab = tabType
            }
        } label: {
            Group {
                Circle()
                    .fill(isActive ? active.fillColor : inactive.fillColor)
                    .frame(width: isActive ? active.length : inactive.length, height: isActive ? active.length : inactive.length)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.yellow)
        }
    }
}

struct ListsButton: View {
    @Binding var activeTab: TabType
    let tabType = TabType.lists
    
    var isActive: Bool { return activeTab == tabType }
    let inactive = ListsAttributes.Inactive()
    let active = ListsAttributes.Active()
    
    var body: some View {
        Button {
            withAnimation {
                activeTab = tabType
            }
        } label: {
            Image("Lists")
                .foregroundColor(isActive ? active.foregroundColor : inactive.foregroundColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.yellow)
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
