//
//  RealmModel+Extensions.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/9/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension RealmModel {
    /// called on startup
    func started() {
        let version = Utilities.getVersionString()
        print("started! +\(version)+")
        if !startedVersions.contains(version) {
            print("start no ocntains")
            startedVersions.append(version)
        }
    }

    /// called in onboarding
    func entered() {
        let version = Utilities.getVersionString()
        print("enteredVersions! +\(version)+")
        if !enteredVersions.contains(version) {
            print("enteredVersions no ocntains")
            enteredVersions.append(version)
        }
        
        if !launchedBefore {
            isFirstLaunch = true /// set to true for importing lists
            launchedBefore = true
        }
    }
}

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

        if filteredRecognitionLanguages.isEmpty {
            return [Settings.Values.RecognitionLanguage.english.rawValue]
        } else {
            return filteredRecognitionLanguages
        }
    }
}

extension UIColor {
    func getFieldColor(for index: Int, realmModel: RealmModel) -> UIColor {
        guard realmModel.highlightsCycleSearchBarColors else { return self }
        let gradation = CGFloat(1) / 15
        let offset = gradation * CGFloat(index)
        return self.offset(by: offset)
    }
}
