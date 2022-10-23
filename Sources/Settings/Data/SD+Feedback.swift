//
//  SD+Feedback.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/5/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension SettingsData {
    static var feedbackSection: SettingsSection = {
        /// general section
        .init(
            rows: [
                .init(
                    configuration: .link(
                        title: "Rate the App",
                        leftIcon: .template(iconName: "star.fill", backgroundColor: UIColor(hex: 0xFFB800)),
                        indicatorStyle: .modal,
                        destination: nil
                    ) {
                        guard let url = URL(string: "https://apps.apple.com/app/id6443969902") else { return }
                        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)

                        components?.queryItems = [
                            URLQueryItem(name: "action", value: "write-review")
                        ]

                        guard let writeReviewURL = components?.url else { return }
                        UIApplication.shared.open(writeReviewURL)
                    }
                ),
                .init(
                    configuration: .link(
                        title: "Report Bugs / Suggest Features",
                        leftIcon: .template(iconName: "sparkles", backgroundColor: UIColor(hex: 0xFF0000)),
                        indicatorStyle: .modal,
                        destination: nil
                    ) {
                        if let url = URL(string: "https://github.com/aheze/OpenFind/issues") {
                            UIApplication.shared.open(url)
                        }
                    }
                )
            ]
        )
    }()
}
