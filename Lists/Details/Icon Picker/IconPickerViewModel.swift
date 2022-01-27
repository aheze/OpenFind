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
    
    
    func filter(search words: [String], completion: @escaping (() -> Void)) {
        DispatchQueue.global(qos: .userInteractive).async {
            let filteredCategories = self.find(words: words)
            self.filteredCategories = filteredCategories
            self.cachedSearches[words] = filteredCategories
            DispatchQueue.main.async {
                completion()
            }
        }
    }

    func find(words: [String]) -> [Category] {
        var cachedCategories: [Category]?
        let sortedCachedSearches = cachedSearches.sorted(by: { $0.key.joined().count > $1.key.joined().count })
        
        print("-> Searching for \(words)")
        for (cachedSearch, categories) in sortedCachedSearches {
            let search = zip(words, cachedSearch)
            print("+ \(cachedSearch) = \(Array(search))")
            if cachedSearch == words { /// exact same search as before
                return categories
            } else if words.count > cachedSearch.count {
                cachedCategories = icons
            } else if search.map({ $0.0.starts(with: $0.1) }).allSatisfy({ $0 }) {
                cachedCategories = categories
                break
            }
        }
        
        let filteredCategories = search(in: cachedCategories ?? icons, for: words)
        return filteredCategories
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
