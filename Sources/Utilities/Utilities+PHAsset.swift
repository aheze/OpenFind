//
//  Utilities+PHAsset.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/22/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Photos
import UIKit

extension PHAsset {
    var originalFilename: String? {
        var fileName: String?

        if #available(iOS 9.0, *) {
            let resources = PHAssetResource.assetResources(for: self)
            if let resource = resources.first {
                fileName = resource.originalFilename
            }
        }

        if fileName == nil {
            /// This is an undocumented workaround that works as of iOS 9.1
            fileName = self.value(forKey: "filename") as? String
        }

        return fileName
    }

    var timeCreatedString: String? {
        guard let creationDate = creationDate else { return nil }
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "d MMM y"

        timeFormatter.locale = Locale(identifier: "en_US_POSIX")
        timeFormatter.dateFormat = "h:mm a"
        timeFormatter.amSymbol = "AM"
        timeFormatter.pmSymbol = "PM"

        let timeAsString = timeFormatter.string(from: creationDate)
        return timeAsString
    }
}
