//
//  SettingsViewController.swift
//  Find
//
//  Created by Andrew on 11/3/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit
import SwiftEntryKit
import RealmSwift
import SPAlert


class SettingsViewController: UIViewController {
    
    let realm = try! Realm()
    var listCategories: Results<FindList>?
    var historyPhotos: Results<HistoryModel>?
    var folderURL = URL(fileURLWithPath: "", isDirectory: true)
    
    @IBOutlet weak var topBlurView: UIVisualEffectView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    @IBOutlet weak var xButton: UIButton!
    
    @IBAction func xButtonPressed(_ sender: Any) {
        if let pvc = self.presentationController {
            pvc.delegate?.presentationControllerDidDismiss?(pvc)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var highlightColorView: UIView!
    @IBOutlet weak var redButton: UIButton!
    @IBOutlet weak var orangeButton: UIButton!
    @IBOutlet weak var yellowButton: UIButton!
    @IBOutlet weak var greenButton: UIButton!
    @IBOutlet weak var tealButton: UIButton!
    @IBOutlet weak var lightblueButton: UIButton!
    @IBOutlet weak var findblueButton: UIButton!
    @IBOutlet weak var purpleButton: UIButton!
    
    let defaults = UserDefaults.standard
    var customizedSettingsBefore = false
    
    @IBAction func colorButtonPressed(_ sender: UIButton) {
        let image = UIImage(systemName: "checkmark")
//        let defaults = UserDefaults.standard
        if customizedSettingsBefore == false {
            defaults.set(true, forKey: "customizedSettingsBool")
        }
        removeChecks()
        switch sender.tag {
        case 3501:
            redButton.setImage(image, for: .normal)
            defaults.set("EB3B5A", forKey: "highlightColor")
            print("red")
        case 3502:
            orangeButton.setImage(image, for: .normal)
            defaults.set("FA8231", forKey: "highlightColor")
            print("org")
        case 3503:
            yellowButton.setImage(image, for: .normal)
            defaults.set("FED330", forKey: "highlightColor")
            print("yel")
        case 3504:
            greenButton.setImage(image, for: .normal)
            defaults.set("20BF6B", forKey: "highlightColor")
            print("gre")
        case 3505:
            tealButton.setImage(image, for: .normal)
            defaults.set("2BCBBA", forKey: "highlightColor")
            print("teal")
        case 3506:
            lightblueButton.setImage(image, for: .normal)
            defaults.set("45AAF2", forKey: "highlightColor")
            print("blue")
        case 3507:
            findblueButton.setImage(image, for: .normal)
            defaults.set("00AEEF", forKey: "highlightColor")
            print("aeef")
        case 3508:
            purpleButton.setImage(image, for: .normal)
            defaults.set("A55EEA", forKey: "highlightColor")
            print("purple")
        default:
            print("WRONG TAG!!")
        }
    }
    func removeChecks() {
        redButton.setImage(nil, for: .normal)
        orangeButton.setImage(nil, for: .normal)
        yellowButton.setImage(nil, for: .normal)
        greenButton.setImage(nil, for: .normal)
        tealButton.setImage(nil, for: .normal)
        lightblueButton.setImage(nil, for: .normal)
        findblueButton.setImage(nil, for: .normal)
        purpleButton.setImage(nil, for: .normal)
    }
    

    @IBOutlet weak var textDetectButton: UIButton!
    @IBAction func textDetectIndicatorPressed(_ sender: Any) {
        
        let textDetectedIndicator = NSLocalizedString("textDetectedIndicator", comment: "Settings def=Text Detected Indicator")
        displayWithURL(urlString: "https://aheze.github.io/FindHelp/Settings-TextDetectIndicator.html", topLabelText: textDetectedIndicator, color: #colorLiteral(red: 0, green: 0.6156862745, blue: 0.937254902, alpha: 1))
    }
    
    @IBOutlet weak var textDetectSwitch: UISwitch!
    @IBAction func textDetectSwitchValue(_ sender: UISwitch) {
        if textDetectSwitch.isOn == true {
            defaults.set(true, forKey: "showTextDetectIndicator")
        } else {
            defaults.set(false, forKey: "showTextDetectIndicator")
        }
    }
    
    
    
    @IBOutlet weak var hapticButton: UIButton!
    @IBAction func hapticFeedbackPressed(_ sender: Any) {
        let hapticFeedback = NSLocalizedString("hapticFeedback", comment: "Settings def=Haptic Feedback")
        
        displayWithURL(urlString: "https://aheze.github.io/FindHelp/Settings-HapticFeedback.html", topLabelText: hapticFeedback, color: #colorLiteral(red: 0, green: 0.6156862745, blue: 0.937254902, alpha: 1))
        
    }
    
    @IBOutlet weak var hapticFeedbackSwitch: UISwitch!
    @IBAction func hapticFeedbackSwitchValue(_ sender: UISwitch) {
        if hapticFeedbackSwitch.isOn == true {
            defaults.set(true, forKey: "hapticFeedback")
        } else {
            defaults.set(false, forKey: "hapticFeedback")
        }
    }
    
    
    
    @IBAction func helpPressed(_ sender: Any) {
        displayHelpController()
    }
    
    
    @IBOutlet weak var tutorialButton: UIButton!
    
    @IBAction func tutorialButtonPressed(_ sender: Any) {
        let watchTutorial = NSLocalizedString("watchTutorial", comment: "Settings def=Watch Tutorial")
        let whichTutorialWatch = NSLocalizedString("whichTutorialWatch",
                                                   comment: "Settings def=Which tutorial do you want to watch?")
        let generalTutorial = NSLocalizedString("generalTutorial", comment: "Settings def=General")
        let photosTutorial = NSLocalizedString("photosTutorial", comment: "Settings def=Photos")
        let listsTutorial = NSLocalizedString("listsTutorial", comment: "Settings def=Lists")
        let listsBuilderTutorial = NSLocalizedString("listsBuilderTutorial", comment: "Settings def=Lists Builder")
        
        let alert = UIAlertController(title: watchTutorial, message: whichTutorialWatch, preferredStyle: .actionSheet)
        
        
        alert.addAction(UIAlertAction(title: generalTutorial, style: UIAlertAction.Style.default, handler: { _ in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "GeneralTutorialViewController") as! GeneralTutorialViewController
            self.present(vc, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: photosTutorial, style: UIAlertAction.Style.default, handler: { _ in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "HistoryTutorialViewController") as! HistoryTutorialViewController
            self.present(vc, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: listsTutorial, style: UIAlertAction.Style.default, handler: { _ in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ListsTutorialViewController") as! ListsTutorialViewController
            self.present(vc, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: listsBuilderTutorial, style: UIAlertAction.Style.default, handler: { _ in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ListsBuilderTutorialViewController") as! ListsBuilderTutorialViewController
            self.present(vc, animated: true, completion: nil)
        }))
        
        let cancel = NSLocalizedString("cancel", comment: "Multipurpose def=Cancel")
        alert.addAction(UIAlertAction(title: cancel, style: UIAlertAction.Style.cancel, handler: nil))
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = tutorialButton
            popoverController.sourceRect = tutorialButton.bounds
        }
        self.present(alert, animated: true, completion: nil)
    }
//    let clear = NSLocalizedString("clear", comment: "Multipurpose def=Clear")
    let deleteLoc = NSLocalizedString("delete", comment: "Multipurpose def=Delete")
    let tapToDismiss = NSLocalizedString("tapToDismiss", comment: "Multipurpose def=Tap to dismiss")
    let cancel = NSLocalizedString("cancel", comment: "Multipurpose def=Cancel")
    
    
    @IBOutlet weak var clearHistButton: UIButton!
    @IBAction func clearHistPressed(_ sender: Any) {
        let deleteAllPhotos = NSLocalizedString("deleteAllPhotos", comment: "Settings def=Delete All Photos")
        let allPhotosAndCachesDeleted = NSLocalizedString("allPhotosAndCachesDeleted",
                                                          comment: "Settings def=All your photos and their caches will be deleted. This action can't be undone.")
        
        
        /// confirm
        let deletedAllPhotos = NSLocalizedString("deletedAllPhotos", comment: "Settings def=Deleted All Photos")
        
        
        
        
        
        let alert = UIAlertController(title: deleteAllPhotos, message: allPhotosAndCachesDeleted, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: deleteLoc, style: UIAlertAction.Style.destructive, handler: { _ in
            var tempPhotos = [HistoryModel]()
            var contents = [SingleHistoryContent]()
            
            var tempFilePaths = [URL]()
            
            if let photoCats = self.historyPhotos {
                for photo in photoCats {
                    
                    let urlString = photo.filePath
                    let finalUrl = self.folderURL.appendingPathComponent(urlString)
//                    guard let finalUrl = URL(string: "\(self.folderURL)\(urlString)") else { print("Invalid File name"); return }
                    tempFilePaths.append(finalUrl)
                    tempPhotos.append(photo)
                    for content in photo.contents {
                        contents.append(content)
                    }
                    
                }
            }
            do {
                try self.realm.write {
                    self.realm.delete(contents)
                    self.realm.delete(tempPhotos)
                }
            } catch {
                print("DELETE PRESSED, but ERROR deleting photos...... \(error)")
            }
            
            print("Deleting from file now")
            let fileManager = FileManager.default
            for filePath in tempFilePaths {
                print("file... \(filePath)")
                do {
                    try fileManager.removeItem(at: filePath)
                } catch {
                    print("Could not delete items: \(error)")
                }
            }
            
            let alertView = SPAlertView(title: deletedAllPhotos, message: self.tapToDismiss, preset: SPAlertPreset.done)
            alertView.duration = 2.6
            alertView.present()
        }))
        alert.addAction(UIAlertAction(title: cancel, style: UIAlertAction.Style.cancel, handler: nil))
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = clearHistButton
            popoverController.sourceRect = clearHistButton.bounds
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBOutlet weak var clearListsButton: UIButton!
    @IBAction func clearListsPressed(_ sender: Any) {
        
        let deleteAllLists = NSLocalizedString("deleteAllLists", comment: "Settings def=Delete All Lists")
        let allYourListsDeleted = NSLocalizedString("allYourListsDeleted",
                                                   comment: "Settings def=All your lists will be deleted. This action can't be undone.")
        let deletedAllLists = NSLocalizedString("deletedAllLists", comment: "Settings def=Deleted All Lists")
        
        
        
        
        
        let alert = UIAlertController(title: deleteAllLists, message: allYourListsDeleted, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: deleteLoc, style: UIAlertAction.Style.destructive, handler: { _ in
            var tempLists = [FindList]()
            if let allLists = self.listCategories {
                for singleList in allLists {
                    tempLists.append(singleList)
                }
            }
            do {
                try self.realm.write {
                    self.realm.delete(tempLists)
                }
            } catch {
                print("DELETE PRESSED, but ERROR deleting photos...... \(error)")
            }
            let alertView = SPAlertView(title: deletedAllLists, message: self.tapToDismiss, preset: SPAlertPreset.done)
            alertView.duration = 2.6
            alertView.present()
        }))
        alert.addAction(UIAlertAction(title: cancel, style: UIAlertAction.Style.cancel, handler: nil))
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = clearListsButton
            popoverController.sourceRect = clearListsButton.bounds
        }
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBOutlet weak var resetSettingsButton: UIButton!
    @IBAction func resetSettingsPressed(_ sender: Any) {
        let resetSettings = NSLocalizedString("resetSettings", comment: "Settings def=Reset Settings")
        let settingsResetToDefault = NSLocalizedString("settingsResetToDefault",
                                                   comment: "Settings def=Settings will be reset to default.")
        let reset = NSLocalizedString("reset", comment: "Settings def=Reset")
        
        
        let alert = UIAlertController(title: resetSettings, message: settingsResetToDefault, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: reset, style: UIAlertAction.Style.default, handler: { _ in
            
            self.defaults.set("00AEEF", forKey: "highlightColor")
            self.defaults.set(true, forKey: "showTextDetectIndicator")
            self.defaults.set(true, forKey: "hapticFeedback")
            
            self.removeChecks()
            let image = UIImage(systemName: "checkmark")
            self.findblueButton.setImage(image, for: .normal)
            
            self.textDetectSwitch.setOn(true, animated: true)
            self.hapticFeedbackSwitch.setOn(true, animated: true)
            
        }))
        alert.addAction(UIAlertAction(title: cancel, style: UIAlertAction.Style.cancel, handler: nil))
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = resetSettingsButton
            popoverController.sourceRect = resetSettingsButton.bounds
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    @IBOutlet weak var otherSettingsView: UIView!
    @IBOutlet weak var middleHelpView: UIView!
    
    @IBOutlet weak var moreSettingsView: UIView!
    
    
    
    @IBOutlet weak var leaveFeedbackView: UIView!
    
    @IBOutlet weak var rateAppView: UIView!
    
    @IBAction func leaveFeedbackPressed(_ sender: Any) {
        defaults.set(true, forKey: "feedbackedAlready")
        let sendFeedback = NSLocalizedString("sendFeedback", comment: "Settings def=Send Feedback")
        
        displayWithURL(urlString: "https://forms.gle/agdyoB9PFfnv8cU1A/", topLabelText: sendFeedback, color: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1))
    }
    
    @IBAction func rateAppPressed(_ sender: Any) {
        print("Rate app")
        if let productURL = URL(string: "https://apps.apple.com/app/id1506500202") {
            var components = URLComponents(url: productURL, resolvingAgainstBaseURL: false)

            // 2.
            components?.queryItems = [
              URLQueryItem(name: "action", value: "write-review")
            ]

            // 3.
            guard let writeReviewURL = components?.url else {
                print("no url")
              return
            }

            // 4.
            UIApplication.shared.open(writeReviewURL)
        }
    }
    
    
    
    
    @IBOutlet weak var creditsView: UIView!
    
    @IBAction func creditsPressed(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let creditsController = storyboard.instantiateViewController(withIdentifier: "CreditsViewController") as! CreditsViewController
        
        present(creditsController, animated: true, completion: nil)

        
        
    }
    
    

    weak var delegate: UIAdaptivePresentationControllerDelegate?
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func viewDidLoad() {
        
        let topInset = topBlurView.frame.height
        scrollView.contentInset.top = topInset
        scrollView.verticalScrollIndicatorInsets.top = topInset
        
        historyPhotos = realm.objects(HistoryModel.self)
        listCategories = realm.objects(FindList.self)
        
        customizedSettingsBefore = defaults.bool(forKey: "customizedSettingsBool")
        
        setUpSettingsRoundedCorners()
        setUpBasic()
    }
 
    
}


extension SettingsViewController {
    func displayWithURL(urlString: String, topLabelText: String, color: UIColor) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewControllerPresent = storyboard.instantiateViewController(withIdentifier: "SingleHelp") as! SingleHelp
        viewControllerPresent.topLabelText = topLabelText
        viewControllerPresent.urlString = urlString
        viewControllerPresent.topViewColor = color
        self.present(viewControllerPresent, animated: true, completion: nil)
        
//        viewControllerPresent.view.layer.cornerRadius = 10
//        viewControllerPresent.view.clipsToBounds = true
//        viewControllerPresent.edgesForExtendedLayout = []
//
//        var attributes = EKAttributes.centerFloat
//        attributes.displayDuration = .infinity
//        attributes.entryInteraction = .absorbTouches
//        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .easeOut)
//        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
//        attributes.screenBackground = .color(color: EKColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3802521008)))
//        attributes.entryBackground = .color(color: .white)
//        attributes.screenInteraction = .absorbTouches
//        attributes.positionConstraints.size.height = .constant(value: screenBounds.size.height - CGFloat(100))
//        attributes.positionConstraints.maxSize = .init(width: .constant(value: 600), height: .constant(value: 800))
//        SwiftEntryKit.display(entry: viewControllerPresent, using: attributes)
    }
    func displayHelpController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let helpViewController = storyboard.instantiateViewController(withIdentifier: "DefaultHelpController") as! DefaultHelpController
        
        let help = NSLocalizedString("help", comment: "Multipurpose def=Help")
        helpViewController.title = help
        helpViewController.helpJsonKey = "SettingsHelpArray"
        
        let navigationController = UINavigationController(rootViewController: helpViewController)
//        navigationController.view.backgroundColor = UIColor.clear
        navigationController.navigationBar.tintColor = UIColor.white
        navigationController.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        navigationController.navigationBar.standardAppearance = navBarAppearance
        navigationController.navigationBar.scrollEdgeAppearance = navBarAppearance
//        navigationController.view.layer.cornerRadius = 10
        UINavigationBar.appearance().barTintColor = .black
//        helpViewController.edgesForExtendedLayout = []
//
        self.present(navigationController, animated: true, completion: nil)
//        var attributes = EKAttributes.centerFloat
//        attributes.displayDuration = .infinity
//        attributes.entryInteraction = .absorbTouches
//        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .easeOut)
//        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
//        attributes.screenBackground = .color(color: EKColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3802521008)))
//        attributes.entryBackground = .color(color: .white)
//        attributes.screenInteraction = .absorbTouches
//        attributes.positionConstraints.size.height = .constant(value: screenBounds.size.height - CGFloat(100))
//        attributes.positionConstraints.maxSize = .init(width: .constant(value: 600), height: .constant(value: 800))
//        SwiftEntryKit.display(entry: navigationController, using: attributes)
    }
}