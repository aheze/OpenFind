//
//  SettingsMVC+Results.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension SettingsMainViewController {
    func find(text: [String]) {
        var paths = [[SettingsRow]]()

        for path in model.paths {
            guard let lastRow = path.last else { return }
                
            if checkIf(row: lastRow, contains: text) {
                paths.append(path)
            }
        }
        
        var sections = [SettingsSection]()
        
        for path in paths {
            /// should be the row in the main page
            guard let firstRow = path.first else { continue }
            
            if case .link(title: let title, leftIcon: let leftIcon, indicatorStyle: _, destination: _, action: _) = firstRow.configuration {
                let row = SettingsRow(
                    configuration: .deepLink(
                        title: title,
                        rows: path
                    )
                )
                
                if let firstIndex = sections.firstIndex(where: { $0.header == title }) {
                    sections[firstIndex].rows.append(row)
                } else {
                    let section = SettingsSection(
                        icon: leftIcon,
                        header: title,
                        rows: [row]
                    )
                    sections.append(section)
                }
            }
        }
        
        model.resultsSections = sections
        
        print("paths: \(paths.count)")
    }
    
    func checkIf(row: SettingsRow, contains text: [String]) -> Bool {
        switch row.configuration {
        case .link(title: let title, leftIcon: let leftIcon, indicatorStyle: let indicatorStyle, destination: let destination, action: let action):
            return text.contains { title.contains($0) }
        case .deepLink(title: let title, rows: let rows):
            return false
        case .toggle(title: let title, storage: let storage):
            return text.contains { title.contains($0) }
        case .button(title: let title, tintColor: let tintColor, rightIconName: let rightIconName, action: let action):
            return text.contains { title.contains($0) }
        case .slider(numberOfSteps: let numberOfSteps, minValue: let minValue, maxValue: let maxValue, minSymbol: let minSymbol, maxSymbol: let maxSymbol, saveAsInt: let saveAsInt, storage: let storage):
            return false
        case .picker(title: let title, choices: let choices, storage: let storage):
            return text.contains { title.contains($0) }
        case .dynamicPicker(title: let title, identifier: let identifier):
            return text.contains { title.contains($0) }
        case .custom(identifier: let identifier):
            return false
        }
    }

    func showResults(_ show: Bool) {
        if show {
            resultsViewController.contentViewBottomC?.isActive = true
            resultsViewController.view.alpha = 1
            pageViewController.view.alpha = 0
        } else {
            resultsViewController.contentViewBottomC?.isActive = false
            resultsViewController.view.alpha = 0
            pageViewController.view.alpha = 1
        }
    }
}
