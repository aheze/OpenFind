//
//  IconPickerViewModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/25/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

class IconPickerViewModel {
    var icons: [Category] = [
        communication,
        weather,
        objectsAndTools,
        devices,
        gaming,
        connectivity,
        transportation,
        human,
        nature,
        editing,
        textFormatting,
        media,
        keyboard,
        commerce,
        time,
        health,
        shapes,
        arrows,
        indices,
        math
    ]
    
    var filteredCategories: [Category]
    var cachedSearches: [[String]: [Category]]
    
    init() {
        self.filteredCategories = icons
        self.cachedSearches = [:]
    }
    
    func filter(words: [String]) {
        
        print("Searching for: \(words)")
        var cachedCategories: [Category]?
        let sortedCachedSearches = cachedSearches.sorted(by: { $0.key.joined().count > $1.key.joined().count })
        
        print("Cached searches: \(cachedSearches.keys), sorted: \(sortedCachedSearches.map { $0.key })")
        for (cachedSearch, categories) in sortedCachedSearches {
            let search = zip(words, cachedSearch)
            if cachedSearch == words {
                self.filteredCategories = categories
                return
            } else if search.map({ $0.0.starts(with: $0.1) }).allSatisfy { $0 } {
                cachedCategories = categories
                break
            }
        }
        
        let start = CFAbsoluteTimeGetCurrent()
        
        print("Searching in: \(cachedCategories)")
        let filteredCategories = search(in: cachedCategories ?? icons, for: words)
        self.filteredCategories = filteredCategories
        cachedSearches[words] = filteredCategories
        
        let diff = CFAbsoluteTimeGetCurrent() - start
        print("🏁🏁🏁 Filter elapsed time measured:  \(diff * 1000) milliseconds for 🔎: \(words) 🏁🏁🏁")
    }

    func search(in categories: [Category], for searchedWords: [String]) -> [Category] {
        var filteredCategories = [Category]()
        
        guard !searchedWords.isEmpty else { return icons }
        for category in categories {
            for icon in category.icons {
                if searchedWords.contains(where: { icon.hasPrefix($0) }) {
                    if let existingCategoryIndex = filteredCategories
                        .firstIndex(where: { $0.categoryName == category.categoryName })
                    {
                        filteredCategories[existingCategoryIndex].icons.append(icon)
                    } else {
                        let newCategory = Category(categoryName: category.categoryName, icons: [icon])
                        filteredCategories.append(newCategory)
                    }
                }
            }
        }
        
        return filteredCategories
    }
}
