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
                CameraButton()
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
    let attributes = PhotosAttributes()
    
    var body: some View {
        Button {
            activeTab = tabType
        } label: {
            Image("Photos")
                .foregroundColor(activeTab == tabType ? attributes.activeForegroundColor.color : attributes.inactiveForegroundColor.color)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.yellow)
        }
    }
}

struct CameraButton: View {
    var body: some View {
        Button {
            print("Camera!")
        } label: {
            Image(systemName: "square.grid.2x2")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.yellow)
        }
    }
}

struct ListsButton: View {
    @Binding var activeTab: TabType
    let tabType = TabType.lists
    let attributes = ListsAttributes()
    
    var body: some View {
        Button {
            activeTab = tabType
        } label: {
            Image("Lists")
                .foregroundColor(activeTab == tabType ? attributes.activeForegroundColor.color : attributes.inactiveForegroundColor.color)
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
