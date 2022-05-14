//
//  SD+Links.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/23/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

extension SettingsData {
    static var linksSection: SettingsSection = {
        .init(
            rows: [
                .init(
                    configuration: .link(
                        title: "Help Center",
                        leftIcon: .template(iconName: "questionmark.circle.fill", backgroundColor: UIColor(hex: 0x44AB00)),
                        indicatorStyle: .modal,
                        destination: nil
                    ) {
                        helpCenter?()
                    }
                ),
                .init(
                    configuration: .link(
                        title: "Join the Discord",
                        leftIcon: .image(imageName: "DiscordIcon", inset: 6, backgroundColor: UIColor(hex: 0x5865F2)),
                        indicatorStyle: .modal,
                        destination: nil
                    ) {
                        joinTheDiscord?()
                    }
                ),
                .init(
                    configuration: .link(
                        title: "Join the Subreddit",
                        leftIcon: .image(imageName: "RedditIcon", inset: 5, backgroundColor: UIColor(hex: 0xFF5700)),
                        indicatorStyle: .modal,
                        destination: nil
                    ) {
                        joinTheReddit?()
                    }
                ),
                .init(
                    configuration: .link(
                        title: "Share App",
                        leftIcon: .template(iconName: "square.and.arrow.up", backgroundColor: UIColor(hex: 0x007EFF)),
                        indicatorStyle: .none,
                        destination: nil
                    ) {
                        shareApp?()
                    }
                )
            ]
        )
    }()
}
