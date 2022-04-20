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
            ToolbarIconButton(iconName: "square.and.arrow.up") {
                sharePhoto()
            }
            .accessibilityLabel("Share")
            .accessibilityHint("Share this photo")
        
            Spacer()
        
            let starDescription = getStarDescription()
            ToolbarIconButton(iconName: starDescription.icon) {
                toggleStar()
            }
            .accessibilityLabel(starDescription.label)
            .accessibilityHint(starDescription.hint)
        
            Spacer()
        
            let infoDescription = getInfoDescription()
            ToolbarIconButton(iconName: infoDescription.icon) {
                toggleToolbar()
            }
            .accessibilityLabel(infoDescription.label)
            .accessibilityHint(infoDescription.hint)
        
            Spacer()
        
            ToolbarIconButton(iconName: "trash") {
                deletePhoto()
            }
            .accessibilityLabel("Delete")
        }
    }
    
    /// 1. icon, 2. voiceover label, 3. voiceover hint
    func getStarDescription() -> (icon: String, label: String, hint: String) {
        if let slidesState = model.slidesState, slidesState.toolbarStarOn {
            return ("star.fill", "Starred", "Tap to unstar")
        }
        return ("star", "Star", "Tap to star")
    }
    
    func getInfoDescription() -> (icon: String, label: String, hint: String) {
        if let slidesState = model.slidesState, slidesState.toolbarInformationOn {
            return ("info.circle.fill", "Info On", "Tap to hide information about this photo")
        }
        return ("info.circle", "Info", "Tap to show information about this photo")
    }

    func toggleStar() {
        if let photo = model.slidesState?.currentPhoto {
            model.star(photos: [photo])
        }
        if let photo = model.slidesState?.currentPhoto {
            withAnimation {
                model.configureToolbar(for: photo)
            }
        }
        model.sortNeededAfterStarChanged = true
    }
    
    func toggleToolbar() {
        if let slidesState = model.slidesState {
            model.slidesState?.toolbarInformationOn = !slidesState.toolbarInformationOn
            model.slidesToolbarInformationOnChanged?()
        }
    }
    
    func deletePhoto() {
        if
            let slidesState = model.slidesState,
            let slidesPhoto = slidesState.getCurrentSlidesPhoto()
        {
            model.delete(photos: [slidesPhoto.findPhoto.photo])
        }
    }
    
    func sharePhoto() {
        if
            let slidesState = model.slidesState,
            let slidesPhoto = slidesState.getCurrentSlidesPhoto()
        {
            model.sharePhotoInSlides?(slidesPhoto.findPhoto.photo)
        }
    }
}
