//
//  WhatsNewConfiguration.swift
//  Find
//
//  Created by Zheng on 6/27/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit
import WhatsNewKit

extension ViewController {
    
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
        
        print("what's new!")
        var whatsNew: WhatsNew?
        var configuration = WhatsNewViewController.Configuration()
        configuration.itemsView.autoTintImage = false
        configuration.titleView.titleColor = #colorLiteral(red: 0, green: 0.6086733891, blue: 0.840379902, alpha: 1)
        configuration.completionButton.backgroundColor = #colorLiteral(red: 0, green: 0.6823529412, blue: 0.937254902, alpha: 1)
        
        
        let language = Locale.preferredLanguages[0]
        if language.contains("en") {
            whatsNew = WhatsNew(
                // The Title
                title: "What's New in\nFind 1.1.0",
                items: [
                    WhatsNew.Item(
                        title: "Chinese Support",
                        subtitle: "We've translated Find into Chinese! However, only English and Pinyin are currently supported in our text recognition engine.",
                        image: UIImage(systemName: "bubble.left.and.bubble.right.fill")?.withTintColor(#colorLiteral(red: 1, green: 0.2843809529, blue: 0, alpha: 1), renderingMode: .alwaysOriginal)
                    ),
                    
                    WhatsNew.Item(
                        title: "History is now Photos",
                        subtitle: "History got kind of confusing, so we renamed it!",
                        image: UIImage(systemName: "photo.fill.on.rectangle.fill")?.withTintColor(#colorLiteral(red: 0.2555771952, green: 0.8299632353, blue: 0, alpha: 1), renderingMode: .alwaysOriginal)
                    ),
                    WhatsNew.Item(
                        title: "What's New Screen",
                        subtitle: "This screen that you're seeing right now is all-new!",
                        image: UIImage(systemName: "doc.text.fill")?.withTintColor(#colorLiteral(red: 0, green: 0.6823529412, blue: 0.937254902, alpha: 1), renderingMode: .alwaysOriginal)
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
        //            title: "What's New in\nFind 1.1.0",
                    title: NSLocalizedString("whatsNewInFindNumber", comment: "WhatsNewConfiguration"),
                    items: [
                        WhatsNew.Item(
        //                    title: "Chinese Support",
                            title: NSLocalizedString("whatsNewChineseSupport", comment: "WhatsNewConfiguration"),
        //                    subtitle: "Chinese is a complex language, but we hope Find can help you out! We've translated Find into Chinese, but only English and Pinyin are currently supported in our OCR engine.",
                            
                            
                            subtitle: NSLocalizedString("whatsNewChineseSupportDetails", comment: "WhatsNewConfiguration"),
                            
                            
                            image: UIImage(systemName: "bubble.left.and.bubble.right.fill")?.withTintColor(#colorLiteral(red: 1, green: 0.2843809529, blue: 0, alpha: 1), renderingMode: .alwaysOriginal)
                        )
//                        ,
                        
                        
//                        WhatsNew.Item(
////                            title: "What's New Screen",
//                            title: NSLocalizedString("whatsNewWhatsNewScreen", comment: "WhatsNewConfiguration"),
////                            subtitle: "This screen that you're seeing right now is all-new!",
//
//
//                            subtitle: NSLocalizedString("whatsNewWhatsNewScreenDetails", comment: "WhatsNewConfiguration"),
//                            image: UIImage(systemName: "doc.text.fill")?.withTintColor(#colorLiteral(red: 0, green: 0.6823529412, blue: 0.937254902, alpha: 1), renderingMode: .alwaysOriginal)
//                        )
                    ]
                )
            configuration.completionButton.title = "前往"
        }
        
        
        
        
        if let whatsNewPresent = whatsNew {
            let whatsNewViewController = WhatsNewViewController(whatsNew: whatsNewPresent, configuration: configuration)
            self.present(whatsNewViewController, animated: true)
        }
        
        
        
        
        
        
        
    }
}

