//
//  SettingsMVC+Results.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

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
        
        withAnimation {
            model.resultsSections = sections
        }
    }
    
    func checkIf(row: SettingsRow, contains text: [String]) -> Bool {
        if let title = row.configuration.getTitle() {
            return Finding.checkIf(realmModel: realmModel, stringToSearchFrom: title, matches: text)
        }
        return false
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
