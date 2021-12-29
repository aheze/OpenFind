////
////  HistorySharing.swift
////  Find
////
////  Created by Zheng on 4/17/20.
////  Copyright © 2020 Andrew. All rights reserved.
////

import UIKit

class HistorySharing: UIActivityItemProvider {
    let temporaryURL: URL
    let filePath: String
    var folderURL: URL
    
    init(filePath: String, folderURL: URL) {
        self.folderURL = folderURL
        self.filePath = filePath
        let newUrl = URL(fileURLWithPath: NSTemporaryDirectory() + "\(filePath).jpg")
        temporaryURL = newUrl
        do {
            let data = Data()
            try data.write(to: temporaryURL)
        } catch {}
        super.init(placeholderItem: temporaryURL)
    }
    
    override var item: Any {
        let newFileUrl = folderURL.appendingPathComponent(filePath)
        do {
            let data = try Data(contentsOf: newFileUrl)
            try data.write(to: temporaryURL)
        } catch {}
        return temporaryURL
    }
}
