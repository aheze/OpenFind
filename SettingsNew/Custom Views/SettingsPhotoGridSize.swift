//
//  SettingsPhotoGridSize.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/5/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct SettingsPhotoGridSize: View {
    @ObservedObject var model: SettingsViewModel
    @ObservedObject var realmModel: RealmModel

    var gridPreview: some View {
        let numberOfColumns = getNumberOfColumns(from: model.pageWidth)

        return HStack(spacing: PhotosConstants.cellSpacing) {
            ForEach(0 ..< numberOfColumns, id: \.self) { index in
                Colors.accent.offset(by: CGFloat(index) * 0.02).color
            }
        }
        .aspectRatio(CGFloat(numberOfColumns), contentMode: .fit)
        .fixedSize(horizontal: false, vertical: true)
    }

    var body: some View {
        VStack(spacing: 0) {
            Color.clear
                .overlay(
                    VStack(spacing: PhotosConstants.cellSpacing) {
                        gridPreview
                        gridPreview
                    },
                    alignment: .top
                )
                .frame(height: 150, alignment: .top)
                .clipped()
                .padding(SettingsConstants.rowHorizontalInsets)
                .padding(SettingsConstants.rowVerticalInsetsFromText)

            Divider()

            SettingsSlider(
                model: model,
                realmModel: realmModel,
                numberOfSteps: nil,
                minValue: 40,
                maxValue: 160,
                minSymbol: .system(name: "square.split.2x2", weight: .regular),
                maxSymbol: .system(name: "square", weight: .regular),
                saveAsInt: false,
                storage: \.$photosMinimumCellLength
            )
        }
        .frame(maxWidth: .infinity)
    }

    func getNumberOfColumns(from availableWidth: CGFloat) -> Int {
        let minimumCellLength = CGFloat(realmModel[keyPath: \.photosMinimumCellLength])
        let (numberOfColumns, _) = minimumCellLength.getColumns(availableWidth: availableWidth)
        return numberOfColumns
    }
}
