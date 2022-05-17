//
//  Photo.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Photos
import UIKit

struct Photo: Hashable {
    var asset: PHAsset
    var metadata: PhotoMetadata?

    func hash(into hasher: inout Hasher) {
        hasher.combine(asset)
    }

    static func == (lhs: Photo, rhs: Photo) -> Bool {
        lhs.asset == rhs.asset
    }

    /// if the photo is ignored or not. If metadata is nil, default to `false`.
    var isIgnored: Bool {
        metadata.map { $0.isIgnored } ?? false
    }

    var isStarred: Bool {
        metadata.map { $0.isStarred } ?? false
    }

    var isScreenshot: Bool {
        asset.mediaSubtypes.contains(.photoScreenshot)
    }
}

struct PhotoMetadata {
    var assetIdentifier = ""
    var isStarred = false
    var isIgnored = false
    var dateScanned: Date?
}

struct PhotoMetadataText {
    var sentences = [Sentence]()
    var scannedInLanguages = [String]()
    var scannedInVersion: String?

    mutating func delete() {
        sentences.removeAll()
        scannedInLanguages.removeAll()
        scannedInVersion = nil
    }
}

enum PhotosSectionCategorization: Equatable, Hashable {
    case date(year: Int, month: Int)

    func getTitle() -> String {
        switch self {
        case .date(let year, let month):
            let dateComponents = DateComponents(year: year, month: month)
            if let date = Calendar.current.date(from: dateComponents) {
                let formatter = DateFormatter()
                if date.isInThisYear {
                    formatter.dateFormat = "MMMM"
                } else {
                    formatter.dateFormat = "MMMM yyyy" /// add year if before
                }
                let string = formatter.string(from: date)
                return string
            }
        }

        return ""
    }
}
