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
        case .link(title: _, leftIcon: _, showRightIndicator: _, destination: let destination):
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
            default:
                return [path]
            }
        default:
            return [path]
        }
    }

    func generateViewController() -> UIViewController {
        let contentView = SettingsPageView(page: self)
        let viewController = HostingController(content: contentView)
        return viewController
    }
}

class HostingController<Content: View>: UIViewController {
    let content: Content
    init(content: Content) {
        self.content = content
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        /**
         Instantiate the base `view`.
         */
        view = UIView()
        view.backgroundColor = .clear

        let hostingController = UIHostingController(rootView: content)
        hostingController.view.frame = view.bounds
        hostingController.view.backgroundColor = .clear
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
}
