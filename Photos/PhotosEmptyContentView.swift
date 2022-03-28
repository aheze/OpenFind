//
//  PhotosEmptyContentView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/26/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import SwiftUI

struct PhotosEmptyContentView: View {
    @ObservedObject var model: PhotosViewModel
    @ObservedObject var sliderViewModel: SliderViewModel
    
    var body: some View {
        if let (title, description) = getText() {
            VStack(spacing: 8) {
                Text(title)
                    .font(.title.weight(.semibold))
                    .opacity(0.5)
            
                Text(description)
                    .fontWeight(.medium)
                    .opacity(0.5)
                    .padding(.horizontal, 32)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    func getText() -> (String, String)? {
        guard model.displayedSections.isEmpty else { return nil }
        switch sliderViewModel.selectedFilter ?? .all {
        case .starred:
            return ("No Starred Photos", "Once you star photos, they will appear here.")
        case .screenshots:
            return ("No Screenshots", "Your screenshots will appear here.")
        case .all:
            return ("No Photos", "You can take photos using your phone's camera, or from within Find by tapping the camera icon.")
        }
    }
}
