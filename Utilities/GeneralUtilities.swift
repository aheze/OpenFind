//
//  Utilities.swift
//  Find
//
//  Created by Zheng on 11/18/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

/// remap `Image` to the current bundle
// struct Image: View {
//
//    let source: Source
//    enum Source {
//        case assetCatalog(String)
//        case systemIcon(String)
//    }
//
//    init(_ name: String) { self.source = .assetCatalog(name) }
//    init(systemName: String) { self.source = .systemIcon(systemName) }
//
//    var body: some View {
//        switch source {
//        case let .assetCatalog(name):
//            SwiftUI.Image(name, bundle: Bundle(identifier: "com.aheze.TabBarController"))
//        case let .systemIcon(name):
//            SwiftUI.Image(systemName: name)
//        }
//    }
// }
