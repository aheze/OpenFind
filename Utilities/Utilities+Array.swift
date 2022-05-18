//
//  Utilities+Array.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/25/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

/// from https://stackoverflow.com/a/46354989/14351818
public extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter{ seen.insert($0).inserted }
    }
}
