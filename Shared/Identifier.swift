//
//  Identifier.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

/// identify something, usually for search bar excluded frames
struct Identifier: Hashable {
    var key: String

    static var cameraSearchBar = Identifier(key: "cameraSearchBar")
    static var photosSearchBar = Identifier(key: "photosSearchBar")
    static var photosSlidesItemCollectionView = Identifier(key: "photosSlidesItemCollectionView")
    static var listsSearchBar = Identifier(key: "listsSearchBar") /// for both the gallery and individual detail search bar, since they share same navigation controller
    static var listsDetailsScreenEdge = Identifier(key: "listsDetailsScreenEdge") /// for the navigation controller
}
