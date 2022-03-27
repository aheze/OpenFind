//
//  Section.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/19/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

struct Section {
    var category: Category?
    var items = [Item]()
    
    enum Category {
        case photosSectionCategorization(PhotosSectionCategorization)
        case placeholder
    }
    
    enum Item {
        case photo(Photo)
        case placeholder /// if no need for a actual item
    }
}
