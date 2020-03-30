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


class SettingsViewController: UIViewController {
    
    let realm = try! Realm()
    var listCategories: Results<FindList>?
    var historyPhotos: Results<HistoryModel>?
    var folderURL = URL(fileURLWithPath: "", isDirectory: true)
    
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
    
    @IBAction func colorButtonPressed(_ sender: UIButton) {
        let image = UIImage(systemName: "checkmark")
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
    

    @IBAction func textDetectIndicatorPressed(_ sender: Any) {
    }
    
    @IBOutlet weak var textDetectSwitch: UISwitch!
    @IBAction func textDetectSwitchValue(_ sender: UISwitch) {
        if textDetectSwitch.isOn == true {
            defaults.set(true, forKey: "showTextDetectIndicator")
        } else {
            defaults.set(false, forKey: "showTextDetectIndicator")
        }
    }
    
    
    
    @IBAction func hapticFeedbackPressed(_ sender: Any) {
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
    
    @IBAction func tutorialButtonPressed(_ sender: Any) {
        print("tutorial")
    }
    
    @IBAction func clearHistPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Clear History", message: "All your photos and their caches will be deleted. This action can't be undone.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Clear", style: UIAlertAction.Style.destructive, handler: { _ in
            var tempPhotos = [HistoryModel]()
            var contents = [SingleHistoryContent]()
            
            var tempFilePaths = [URL]()
            
            if let photoCats = self.historyPhotos {
                for photo in photoCats {
                    
                    let urlString = photo.filePath
                    guard let finalUrl = URL(string: "\(self.folderURL)\(urlString)") else { print("Invalid File name"); return }
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
            print("CLEAR hist")
            
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
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func clearListsPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Clear Lists", message: "All your lists will be deleted. This action can't be undone.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Clear", style: UIAlertAction.Style.destructive, handler: { _ in
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
            print("CLEAR hist")
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        print("clear list")
    }
    
    @IBAction func resetSettingsPressed(_ sender: Any) {
        print("reset sett")
        let alert = UIAlertController(title: "Reset Settings", message: "Settings will be reset to default.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Reset", style: UIAlertAction.Style.default, handler: { _ in
            
            self.defaults.set("00AEEF", forKey: "highlightColor")
            self.defaults.set(true, forKey: "showTextDetectIndicator")
            self.defaults.set(true, forKey: "hapticFeedback")
            
            self.removeChecks()
            let image = UIImage(systemName: "checkmark")
            if let hexString = self.defaults.string(forKey: "highlightColor") {
                switch hexString {
                case "EB3B5A":
                    self.redButton.setImage(image, for: .normal)
                case "FA8231":
                    self.orangeButton.setImage(image, for: .normal)
                case "FED330":
                    self.yellowButton.setImage(image, for: .normal)
                case "20BF6B":
                    self.greenButton.setImage(image, for: .normal)
                case "2BCBBA":
                    self.tealButton.setImage(image, for: .normal)
                case "45AAF2":
                    self.lightblueButton.setImage(image, for: .normal)
                case "00AEEF":
                    self.findblueButton.setImage(image, for: .normal)
                case "A55EEA":
                    self.purpleButton.setImage(image, for: .normal)
                default:
                    print("WRONG TAG!!")
                }
            }
            
            self.textDetectSwitch.setOn(true, animated: true)
            self.hapticFeedbackSwitch.setOn(true, animated: true)
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    @IBOutlet weak var otherSettingsView: UIView!
    @IBOutlet weak var middleHelpView: UIView!
    
    @IBOutlet weak var moreSettingsView: UIView!
    
    
    
    @IBOutlet weak var leaveFeedbackView: UIView!
    
    @IBOutlet weak var rateAppView: UIView!
    
    @IBAction func leaveFeedbackPressed(_ sender: Any) {
        displayWithURL(urlString: "https://forms.gle/agdyoB9PFfnv8cU1A/", topLabelText: "Send Feedback", color: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1))
    }
    
    @IBAction func rateAppPressed(_ sender: Any) {
        print("Rate app")
    }
    
    
    
    
    @IBOutlet weak var creditsView: UIView!
    
    @IBAction func creditsPressed(_ sender: Any) {
        print("credits")
    }
    
    

    weak var delegate: UIAdaptivePresentationControllerDelegate?
    
    
    override func viewDidLoad() {
        
        historyPhotos = realm.objects(HistoryModel.self)
        listCategories = realm.objects(FindList.self)
//        let defaults = UserDefaults.standard
//        defaults.set(25, forKey: "Age")
//        defaults.set(true, forKey: "UseTouchID")
//        defaults.set(CGFloat.pi, forKey: "Pi")
//
//        defaults.set("Paul Hudson", forKey: "Name")
//        defaults.set(Date(), forKey: "LastRun")
//        
        
        setUpSettingsRoundedCorners()
        setUpBasic()
//        addGestureRecognizers()
    }
 
    
}


extension SettingsViewController {
    func displayWithURL(urlString: String, topLabelText: String, color: UIColor) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewControllerPresent = storyboard.instantiateViewController(withIdentifier: "SingleHelp") as! SingleHelp
        viewControllerPresent.topLabelText = topLabelText
        viewControllerPresent.urlString = urlString
        viewControllerPresent.topViewColor = color
        
        viewControllerPresent.view.layer.cornerRadius = 10
//        view.layer.cornerRadius = 10
        viewControllerPresent.view.clipsToBounds = true
        viewControllerPresent.edgesForExtendedLayout = []
        
        var attributes = EKAttributes.centerFloat
        attributes.displayDuration = .infinity
        attributes.entryInteraction = .absorbTouches
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .easeOut)
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
        attributes.screenBackground = .color(color: EKColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3802521008)))
        attributes.entryBackground = .color(color: .white)
        attributes.screenInteraction = .absorbTouches
        attributes.positionConstraints.size.height = .constant(value: UIScreen.main.bounds.size.height - CGFloat(100))
        SwiftEntryKit.display(entry: viewControllerPresent, using: attributes)
    }
    
    func displayHelpController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let helpViewController = storyboard.instantiateViewController(withIdentifier: "DefaultHelpController") as! DefaultHelpController
        
        helpViewController.title = "Help"
        helpViewController.helpJsonKey = "SettingsHelpArray"
        
//        helpViewController.title = "Find Help"
//        helpViewController.helpJsonKey = "HistoryFindHelpArray"
        let navigationController = UINavigationController(rootViewController: helpViewController)
        navigationController.view.backgroundColor = UIColor.clear
        navigationController.navigationBar.tintColor = UIColor.white
        navigationController.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        navigationController.navigationBar.standardAppearance = navBarAppearance
        navigationController.navigationBar.scrollEdgeAppearance = navBarAppearance
        navigationController.view.layer.cornerRadius = 10
        UINavigationBar.appearance().barTintColor = .black
        helpViewController.edgesForExtendedLayout = []
        
        var attributes = EKAttributes.centerFloat
        attributes.displayDuration = .infinity
        attributes.entryInteraction = .absorbTouches
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .easeOut)
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
        attributes.screenBackground = .color(color: EKColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3802521008)))
        attributes.entryBackground = .color(color: .white)
        attributes.screenInteraction = .absorbTouches
        attributes.positionConstraints.size.height = .constant(value: UIScreen.main.bounds.size.height - CGFloat(100))
        
        SwiftEntryKit.display(entry: navigationController, using: attributes)
    }
}
