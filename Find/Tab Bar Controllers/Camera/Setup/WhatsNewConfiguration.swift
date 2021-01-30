//
//  WhatsNewConfiguration.swift
//  Find
//
//  Created by Zheng on 6/27/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit
import WhatsNewKit

struct WhatsNewConfig {
    static func getWhatsNew() -> (WhatsNew?, WhatsNewViewController.Configuration) {
        var whatsNew: WhatsNew?
        var configuration = WhatsNewViewController.Configuration()
        configuration.itemsView.autoTintImage = false
        configuration.titleView.titleColor = #colorLiteral(red: 0, green: 0.6086733891, blue: 0.840379902, alpha: 1)
        configuration.completionButton.backgroundColor = #colorLiteral(red: 0, green: 0.6823529412, blue: 0.937254902, alpha: 1)
        
        
        let language = Locale.preferredLanguages[0]
        if language.contains("en") {
            whatsNew = WhatsNew(
                // The Title
                title: "What's New in\nFind 1.2",
                items: [
                    WhatsNew.Item(
                        title: "Refreshed Interface",
                        subtitle: "Say goodbye to that weird floating popup button! We've added a nice, clean tab bar instead.",
                        image: UIImage(systemName: "sparkles")?.withTintColor(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), renderingMode: .alwaysOriginal)
                    ),
                    
                    WhatsNew.Item(
                        title: "Redesigned Photos",
                        subtitle: "It's now linked to the Photos app, so you can find from your existing photos.",
                        image: UIImage(systemName: "photo.fill.on.rectangle.fill")?.withTintColor(#colorLiteral(red: 0.2555771952, green: 0.8299632353, blue: 0, alpha: 1), renderingMode: .alwaysOriginal)
                    ),
                    WhatsNew.Item(
                        title: "Upgraded Camera",
                        subtitle: "You can now pause the live preview and cache it for super-accurate results.",
                        image: UIImage(systemName: "camera.fill")?.withTintColor(#colorLiteral(red: 0, green: 0.6823529412, blue: 0.937254902, alpha: 1), renderingMode: .alwaysOriginal)
                    ),
                    WhatsNew.Item(
                        title: "And literally so much more",
                        subtitle: "If you were to compare Find 1.1 and Find 1.2, you would think you were looking at 2 different apps.",
                        image: UIImage(systemName: "plus.app.fill")?.withTintColor(#colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), renderingMode: .alwaysOriginal)
                    )
                ]
            )
            configuration.titleView.secondaryColor = .init(
                // The start index
                startIndex: 14,
                // The length of characters
                length: 10,
                // The secondary color to apply
                color: #colorLiteral(red: 0, green: 0.6823529412, blue: 0.937254902, alpha: 1)
            )
            
            configuration.completionButton.title = "Continue"
        } else {
            whatsNew = WhatsNew(
                    title: NSLocalizedString("whatsNewInFindNumber", comment: "WhatsNewConfiguration"),
                    items: [
                        WhatsNew.Item(
                            title: NSLocalizedString("whatsNewChineseSupport", comment: "WhatsNewConfiguration"),
                            subtitle: NSLocalizedString("whatsNewChineseSupportDetails", comment: "WhatsNewConfiguration"),
                            image: UIImage(systemName: "bubble.left.and.bubble.right.fill")?.withTintColor(#colorLiteral(red: 1, green: 0.2843809529, blue: 0, alpha: 1), renderingMode: .alwaysOriginal)
                        )
                    ]
                )
            configuration.completionButton.title = "前往"
        }
        
        return (whatsNew, configuration)
    }
}
extension CameraViewController {
    
    func dismissWhatsNew(completion: @escaping () -> Void) {
        self.whatsNewHeightC.constant = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.whatsNewView.alpha = 0
            self.whatsNewButton.alpha = 0
            self.whatsNewView.layoutIfNeeded()
        }) { _ in
            self.shouldPresentWhatsNew = false
            completion()
        }
    }
    
    func displayWhatsNew() {
        let (whatsNew, configuration) = WhatsNewConfig.getWhatsNew()
        if let whatsNewPresent = whatsNew {
            let whatsNewViewController = WhatsNewViewController(whatsNew: whatsNewPresent, configuration: configuration)
            self.present(whatsNewViewController, animated: true)
        }
    }
}

