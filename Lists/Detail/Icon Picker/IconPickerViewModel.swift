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
        math,
        miscellaneous
    ]
    
    var selectedIcon: String {
        didSet {
            iconChanged?(selectedIcon)
        }
    }

    var iconChanged: ((String) -> Void)?
    
    var filteredCategories: [Category]
    var cachedSearches: [[String]: [Category]]
    
    var getRealmModel: (() -> RealmModel)?
    
    init(selectedIcon: String) {
        self.selectedIcon = selectedIcon
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
        
        for (cachedSearch, categories) in sortedCachedSearches {
            let search = zip(words, cachedSearch)
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
        guard let realmModel = getRealmModel?() else { return [] }
        var filteredCategories = [Category]()
        
        guard !searchedWords.isEmpty else { return icons }
        for category in categories {
            for icon in category.icons {
                let contains = Finding.checkIf(realmModel: realmModel, string: icon, matches: searchedWords)
                
                if contains {
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
