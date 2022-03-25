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
        
            ToolbarIconButton(iconName: infoIcon()) {
                toggleToolbar()
            }
        
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
    
    func infoIcon() -> String {
        if let slidesState = model.slidesState, slidesState.toolbarInformationOn {
            return "info.circle.fill"
        }
        return "info.circle"
    }
    func toggleStar() {
        if
            let slidesState = model.slidesState,
            let findPhoto = slidesState.getCurrentFindPhoto()
        {
            var newPhoto = findPhoto.photo
            if let metadata = newPhoto.metadata {
                let isStarred = !metadata.isStarred
                newPhoto.metadata?.isStarred = !metadata.isStarred
                model.updatePhotoMetadata(photo: newPhoto, reloadCell: true)
                model.slidesState?.toolbarStarOn = isStarred
            } else {
                let metadata = PhotoMetadata(
                    assetIdentifier: findPhoto.photo.asset.localIdentifier,
                    sentences: [],
                    dateScanned: nil,
                    isStarred: true,
                    isIgnored: false
                )
                newPhoto.metadata = metadata
                model.updatePhotoMetadata(photo: newPhoto, reloadCell: true)
                model.slidesState?.toolbarStarOn = metadata.isStarred
            }
            
            model.sortNeeded = true
        }
    }
    
    func toggleToolbar() {
        if let slidesState = model.slidesState {
            model.slidesState?.toolbarInformationOn = !slidesState.toolbarInformationOn
            model.slidesState?.toolbarInformationOnChanged?()
        }
    }
}
