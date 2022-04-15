//
//  RealmModel+Extensions.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/9/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension RealmModel {
    var thumbnailSize: CGSize {
        let scale = UIScreen.main.scale
        let length = photosMinimumCellLength * 3 / 2 /// slightly clearer
        let thumbnailSize = CGSize(width: length * scale, height: photosMinimumCellLength * scale)
        return thumbnailSize
    }

    func getCurrentRecognitionLanguages(accurateMode: Bool) -> [String] {
        let recognitionLanguages = [findingPrimaryRecognitionLanguage, findingSecondaryRecognitionLanguage]

        let filteredRecognitionLanguages = recognitionLanguages.filter {
            if let language = Settings.Values.RecognitionLanguage(rawValue: $0) {
                let available = language.isAvailableFor(
                    accurateMode: accurateMode,
                    version: Utilities.deviceVersion()
                )
                return available
            }
            return false
        }
        print("Lang: ->>> \(filteredRecognitionLanguages)")
        if filteredRecognitionLanguages.isEmpty {
            return [Settings.Values.RecognitionLanguage.english.rawValue]
        } else {
            return filteredRecognitionLanguages
        }
    }
}
