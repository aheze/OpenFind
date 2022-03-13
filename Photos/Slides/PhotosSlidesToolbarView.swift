//
//  PhotosSlidesToolbarView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/18/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct PhotosSlidesToolbarView: View {
    @ObservedObject var model: PhotosViewModel

    var body: some View {
        HStack {
            ToolbarIconButton(iconName: "square.and.arrow.up") {}
        
            Spacer()
        
            ToolbarIconButton(iconName: starIcon()) {
                toggleStar()
            }
        
            Spacer()
        
            ToolbarIconButton(iconName: "info.circle") {}
        
            Spacer()
        
            ToolbarIconButton(iconName: "trash") {}
        }
    }
    
    func starIcon() -> String {
        if let slidesState = model.slidesState, slidesState.toolbarStarOn {
            return "star.fill"
        }
        return "star"
    }
    
    func toggleStar() {
        if let (findPhoto, _) = model.slidesState?.getCurrentFindPhotoAndIndex() {
            if var metadata = findPhoto.photo.metadata {
                metadata.isStarred.toggle()
                model.updatePhotoMetadata(photo: findPhoto.photo, metadata: metadata, reloadCell: true)
                model.slidesState?.toolbarStarOn = metadata.isStarred
            } else {
                let metadata = PhotoMetadata(
                    assetIdentifier: findPhoto.photo.asset.localIdentifier,
                    sentences: [],
                    isScanned: false,
                    isStarred: true
                )
                model.updatePhotoMetadata(photo: findPhoto.photo, metadata: metadata, reloadCell: true)
                model.slidesState?.toolbarStarOn = metadata.isStarred
            }
        }
    }
}
