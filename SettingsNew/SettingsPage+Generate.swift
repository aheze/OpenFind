//
//  SettingsPage+Generate.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

extension SettingsPage {
    /// generate all possibile paths
    func generatePaths() -> [[SettingsRow]] {
        switch configuration {
        case .sections(sections: let sections):
            var arrayOfPaths = [[SettingsRow]]()
            for section in sections {
                for row in section.rows {
                    let paths = generateRowPaths(for: [row])
                    arrayOfPaths += paths
                }
            }
            return arrayOfPaths
        default: return [[]]
        }
    }

    /// `path` - a path of rows whose last element is the row to generate
    func generateRowPaths(for path: [SettingsRow]) -> [[SettingsRow]] {
        guard let latestRow = path.last else { return [[]] }

        switch latestRow.configuration {
        case .link(title: _, leftIcon: _, indicatorStyle: _, destination: let destination, action: _):
            if let destination = destination {
                switch destination.configuration {
                case .sections(sections: let sections):

                    /// include the current row as a path
                    var paths = [path]

                    for section in sections {
                        for row in section.rows {
                            let currentPath = path + [row]
                            let generatedPaths = generateRowPaths(for: currentPath)
                            paths += generatedPaths
                        }
                    }
                    return paths
                default: break
                }
            }
        default: break
        }
        return [path]
    }

    func generateViewController(model: SettingsViewModel, realmModel: RealmModel) -> SettingsPageViewController {
        let viewController = SettingsPageViewController(model: model, realmModel: realmModel, page: self)
        return viewController
    }
}
