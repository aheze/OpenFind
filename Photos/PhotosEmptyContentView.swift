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
    @ObservedObject var realmModel: RealmModel
    @ObservedObject var sliderViewModel: SliderViewModel
    
    var body: some View {
        if model.loaded {
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
        } else {
            gridPreview
        }
    }
    
    var gridPreview: some View {
        GeometryReader { geometry in
            let (numberOfColumns, columnWidth) = getNumberOfColumnsAndWidth(from: geometry.size.width)
            let numberOfRows = Int(ceil(geometry.size.height / columnWidth))
            
            VStack(spacing: PhotosConstants.cellSpacing) {
                ForEach(0 ..< numberOfRows, id: \.self) { row in
                    HStack(spacing: PhotosConstants.cellSpacing) {
                        ForEach(0 ..< numberOfColumns, id: \.self) { column in
                            Colors.accent.offset(by: CGFloat(row * column) * 0.001)
                                .color
                        }
                    }
                    .aspectRatio(CGFloat(numberOfColumns), contentMode: .fit)
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
            .opacity(0.5)
        }
    }

    func getNumberOfColumnsAndWidth(from availableWidth: CGFloat) -> (Int, CGFloat) {
        let minimumCellLength = CGFloat(realmModel.photosMinimumCellLength)
        return minimumCellLength.getColumns(availableWidth: availableWidth)
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
