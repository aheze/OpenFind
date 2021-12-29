//
//  CameraVC+Settings.swift
//  Find
//
//  Created by Zheng on 1/28/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import SupportDocs
import WhatsNewKit

extension CameraViewController {
    func setupSettings() {
        let settingsVC = SettingsViewController()
        settingsVC.presentationController?.delegate = self
        self.present(settingsVC, animated: true)
        
        Settings.Bridge.dismissed = { [weak self] in
            self?.cameBackFromSettings?()
        }
        
        Settings.Bridge.presentTopOfTheList = { [weak self] in
            SwiftEntryKitTemplates().displaySEK(
                message: "Must be at top of list and only works when Cached",
                backgroundColor: #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1),
                textColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
                location: .top,
                duration: CGFloat(2)
            )
        }
        
        Settings.Bridge.presentRequiresSoftwareUpdate = { [weak self] versionNeededString in
            SwiftEntryKitTemplates().displaySEK(
                message: "Requires software update to iOS \(versionNeededString)+",
                backgroundColor: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1),
                textColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
                location: .top,
                duration: CGFloat(2)
            )
        }
        
        Settings.Bridge.presentWhatsNew = { [weak self] in
            guard let self = self else { return }
            let (whatsNew, configuration) = WhatsNewConfig.getWhatsNew()
            if let whatsNewPresent = whatsNew {
                let whatsNewViewController = WhatsNewViewController(whatsNew: whatsNewPresent, configuration: configuration)
                self.present(whatsNewViewController, animated: true)
            }
        }
        
        Settings.Bridge.presentLicenses = { [weak self] in
            self?.presentLicenses()
        }
        
        Settings.Bridge.presentGeneralTutorial = { [weak self] in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "GeneralTutorialViewController") as! GeneralTutorialViewController
            self?.present(vc, animated: true, completion: nil)
        }
        
        Settings.Bridge.presentPhotosTutorial = { [weak self] in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "HistoryTutorialViewController") as! HistoryTutorialViewController
            self?.present(vc, animated: true, completion: nil)
        }
        
        Settings.Bridge.presentListsTutorial = { [weak self] in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ListsTutorialViewController") as! ListsTutorialViewController
            self?.present(vc, animated: true, completion: nil)
        }
        
        Settings.Bridge.presentListsBuilderTutorial = { [weak self] in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "ListsBuilderTutorialViewController") as! ListsBuilderTutorialViewController
            self?.present(vc, animated: true, completion: nil)
        }
        
        Settings.Bridge.presentShareScreen = { [weak self] in
            
        }
    }
}

extension CameraViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        cameBackFromSettings?()
    }
}


