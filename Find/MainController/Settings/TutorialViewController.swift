//
//  TutorialViewController.swift
//  Find
//
//  Created by Zheng on 4/1/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit
//import paper_onboarding
import SnapKit
import SwiftEntryKit

class GeneralTutorialViewController: UIViewController, PaperOnboardingDelegate, PaperOnboardingDataSource {
//    let getStartedButton = UIButton()
    
    @IBOutlet weak var paperOnboarding: PaperOnboarding!
    
    @IBOutlet weak var goButton: UIButton!
    @IBAction func goButtonPressed(_ sender: Any) {
        SwiftEntryKit.dismiss()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("TUTO")
        
        goButton.layer.cornerRadius = 6
        paperOnboarding.delegate = self
        paperOnboarding.dataSource = self
        
        goButton.isHidden = true
        goButton.alpha = 0
        goButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
    func onboardingWillTransitonToIndex(_ index: Int) {
        if index == 5 {
            goButton.isHidden = false
            goButton.alpha = 0
            UIView.animate(withDuration: 0.05, animations: {
                self.goButton.transform = CGAffineTransform.identity
                self.goButton.alpha = 1
            })
        } else {
            goButton.alpha = 1
            UIView.animate(withDuration: 0.05, animations: {
                self.goButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                self.goButton.alpha = 0
            }) { _ in
                self.goButton.isHidden = true
            }

        }
    }
    
    
    func onboardingItem(at index: Int) -> OnboardingItemInfo {
      return [
        OnboardingItemInfo(informationImage: UIImage(named: "Swelcome")!,
                                      title: "Welcome to Find",
                                description: "Swipe to get started",
                                   pageIcon: UIImage(),
                                   color: UIColor(named: "OnboardingGray")!,
                                 titleColor: UIColor.black,
                           descriptionColor: UIColor.darkGray,
                           titleFont: UIFont.systemFont(ofSize: 30, weight: .bold),
                            descriptionFont: UIFont.systemFont(ofSize: 17)),
        
        OnboardingItemInfo(informationImage: UIImage(named: "Swhatis")!,
                   title: "What is Find?",
             description: "Find is Command+F for camera. Find words in books, worksheets, nutrition labels... Anywhere as long as there's text!",
                pageIcon: UIImage(named: "1icon")!,
                color: UIColor(named: "OnboardingGray")!,
              titleColor: UIColor.black,
        descriptionColor: UIColor.darkGray,
        titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
         descriptionFont: UIFont.systemFont(ofSize: 17)),
        
        OnboardingItemInfo(informationImage: UIImage(named: "Ssearchfield")!,
                   title: "Find words",
             description: "Tap the Search Field at the top of the screen",
                pageIcon: UIImage(named: "2icon")!,
                color: UIColor(named: "OnboardingGray")!,
              titleColor: UIColor.black,
        descriptionColor: UIColor.darkGray,
        titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
         descriptionFont: UIFont.systemFont(ofSize: 17)),

        OnboardingItemInfo(informationImage: UIImage(named: "Sshutter")!,
                   title: "Take photos",
             description: "Tap the shutter button. Your photos will appear in your History, where you can Find from them again and again and again...",
                pageIcon: UIImage(named: "3icon")!,
                   color: UIColor(named: "OnboardingGray")!,
              titleColor: UIColor.black,
        descriptionColor: UIColor.darkGray,
        titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
         descriptionFont: UIFont.systemFont(ofSize: 17)),

       OnboardingItemInfo(informationImage: UIImage(named: "Smenu")!,
                  title: "Access the Menu",
            description: "Your History, Lists, and Settings are here. Check it out!",
               pageIcon: UIImage(named: "4icon")!,
                  color: UIColor(named: "OnboardingGray")!,
             titleColor: UIColor.black,
       descriptionColor: UIColor.darkGray,
       titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
        descriptionFont: UIFont.systemFont(ofSize: 17)),
       
       OnboardingItemInfo(informationImage: UIImage(named: "Sjitter")!,
                  title: "Before you start...",
            description: "To ensure the most accurate results, please make sure to hold your phone as steady as possible.",
               pageIcon: UIImage(named: "5icon")!,
                  color: UIColor(named: "OnboardingGray")!,
             titleColor: UIColor.black,
       descriptionColor: UIColor.darkGray,
       titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
        descriptionFont: UIFont.systemFont(ofSize: 17))
        ][index]
    }
    func onboardingItemsCount() -> Int {
       return 6
    }
}

class HistoryTutorialViewController: UIViewController, PaperOnboardingDelegate, PaperOnboardingDataSource {
//    let getStartedButton = UIButton()
    
    
    @IBOutlet weak var paperOnboarding: PaperOnboarding!
    
    @IBOutlet weak var goButton: UIButton!
    
    @IBAction func histGoButtonPressed(_ sender: Any) {
        SwiftEntryKit.dismiss()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("TUTO")
        goButton.layer.cornerRadius = 6
        paperOnboarding.delegate = self
        paperOnboarding.dataSource = self
        
        goButton.isHidden = true
        goButton.alpha = 0
        goButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        
    }
    
    func onboardingWillTransitonToIndex(_ index: Int) {
        if index == 3 {
            goButton.alpha = 0
            goButton.isHidden = false
            UIView.animate(withDuration: 0.05, animations: {
                self.goButton.transform = CGAffineTransform.identity
                self.goButton.alpha = 1
            })
        } else {
            goButton.alpha = 1
            UIView.animate(withDuration: 0.05, animations: {
                self.goButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                self.goButton.alpha = 0
            }) { _ in
                self.goButton.isHidden = true
            }

        }
    }
    
    
    func onboardingItem(at index: Int) -> OnboardingItemInfo {
      return [
        OnboardingItemInfo(informationImage: UIImage(named: "Hwelcome")!,
                                      title: "History...",
                                description: "...where all your photos live!",
                                   pageIcon: UIImage(),
                                   color: UIColor(named: "OnboardingGray")!,
                                 titleColor: UIColor.black,
                           descriptionColor: UIColor.darkGray,
                           titleFont: UIFont.systemFont(ofSize: 30, weight: .bold),
                            descriptionFont: UIFont.systemFont(ofSize: 17)),
        
        OnboardingItemInfo(informationImage: UIImage(named: "Hselect")!,
                   title: "Select photos",
             description: "Tap the select button, and the History Controls will pop up!",
                pageIcon: UIImage(named: "1icon")!,
                   color: UIColor(named: "OnboardingGray")!,
              titleColor: UIColor.black,
        descriptionColor: UIColor.darkGray,
        titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
         descriptionFont: UIFont.systemFont(ofSize: 17)),
        
        OnboardingItemInfo(informationImage: UIImage(named: "Hfind")!,
                   title: "Find from History",
             description: "Select a few photos, then tap the Find icon. Then, enter the text that you want to find! ",
                pageIcon: UIImage(named: "2icon")!,
                   color: UIColor(named: "OnboardingGray")!,
              titleColor: UIColor.black,
        descriptionColor: UIColor.darkGray,
        titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
         descriptionFont: UIFont.systemFont(ofSize: 17)),

        OnboardingItemInfo(informationImage: UIImage(named: "Hcache")!,
                   title: "Cache photos",
             description: "Find uses OCR, which is often time consuming. Solution: Caching (pre-searching an image). Results will appear instantly when finding from Cached photos!",
                pageIcon: UIImage(named: "3icon")!,
                   color: UIColor(named: "OnboardingGray")!,
              titleColor: UIColor.black,
        descriptionColor: UIColor.darkGray,
        titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
         descriptionFont: UIFont.systemFont(ofSize: 17))
        ][index]
    }

    func onboardingItemsCount() -> Int {
       return 4
    }
}
class ListsTutorialViewController: UIViewController, PaperOnboardingDelegate, PaperOnboardingDataSource {
//    let getStartedButton = UIButton()
    
    
    @IBOutlet weak var paperOnboarding: PaperOnboarding!
    
    @IBOutlet weak var goButton: UIButton!
    
    @IBAction func listsGoButtonPressed(_ sender: Any) {
        SwiftEntryKit.dismiss()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("TUTO")
        
        goButton.layer.cornerRadius = 6
        paperOnboarding.delegate = self
        paperOnboarding.dataSource = self
        
        goButton.isHidden = true
        goButton.alpha = 0
        goButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
    func onboardingWillTransitonToIndex(_ index: Int) {
        if index == 3 {
            goButton.alpha = 0
            goButton.isHidden = false
            UIView.animate(withDuration: 0.05, animations: {
                self.goButton.transform = CGAffineTransform.identity
                self.goButton.alpha = 1
            })
        } else {
            goButton.alpha = 1
            UIView.animate(withDuration: 0.05, animations: {
                self.goButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                self.goButton.alpha = 0
            }) { _ in
                self.goButton.isHidden = true
            }

        }
    }
    
    
    func onboardingItem(at index: Int) -> OnboardingItemInfo {
      return [
        OnboardingItemInfo(informationImage: UIImage(named: "Lwelcome")!,
                                      title: "Lists...",
                                description: "...find multiple words at the same time!",
                                   pageIcon: UIImage(),
                                   color: UIColor(named: "OnboardingGray")!,
                                 titleColor: UIColor.black,
                           descriptionColor: UIColor.darkGray,
                           titleFont: UIFont.systemFont(ofSize: 30, weight: .bold),
                            descriptionFont: UIFont.systemFont(ofSize: 17)),
        
        OnboardingItemInfo(informationImage: UIImage(named: "LaddList")!,
                   title: "Make a list",
             description: "Tap the Add button",
                pageIcon: UIImage(named: "1icon")!,
                   color: UIColor(named: "OnboardingGray")!,
              titleColor: UIColor.black,
        descriptionColor: UIColor.darkGray,
        titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
         descriptionFont: UIFont.systemFont(ofSize: 17)),
        
        OnboardingItemInfo(informationImage: UIImage(named: "LaddMatch")!,
                   title: "Add some matches",
             description: "Matches are the words that Find searches for when you use the list",
                pageIcon: UIImage(named: "2icon")!,
                   color: UIColor(named: "OnboardingGray")!,
              titleColor: UIColor.black,
        descriptionColor: UIColor.darkGray,
        titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
         descriptionFont: UIFont.systemFont(ofSize: 17)),

        OnboardingItemInfo(informationImage: UIImage(named: "Luse")!,
                   title: "Use the list",
             description: "Your lists will appear above the keyboard, whether you are Finding using the camera or from history",
                pageIcon: UIImage(named: "3icon")!,
                   color: UIColor(named: "OnboardingGray")!,
              titleColor: UIColor.black,
        descriptionColor: UIColor.darkGray,
        titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
         descriptionFont: UIFont.systemFont(ofSize: 17))
        ][index]
    }

    func onboardingItemsCount() -> Int {
       return 4
    }
}
class ListsBuilderTutorialViewController: UIViewController, PaperOnboardingDelegate, PaperOnboardingDataSource {
//    let getStartedButton = UIButton()
    
    
    @IBOutlet weak var paperOnboarding: PaperOnboarding!
    
    @IBOutlet weak var goButton: UIButton!
    
    @IBAction func listsGoButtonPressed(_ sender: Any) {
        SwiftEntryKit.dismiss()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("TUTO")
        
        goButton.layer.cornerRadius = 6
        paperOnboarding.delegate = self
        paperOnboarding.dataSource = self
        
        goButton.isHidden = true
        goButton.alpha = 0
        goButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
    func onboardingWillTransitonToIndex(_ index: Int) {
        if index == 3 {
            goButton.alpha = 0
            goButton.isHidden = false
            UIView.animate(withDuration: 0.05, animations: {
                self.goButton.transform = CGAffineTransform.identity
                self.goButton.alpha = 1
            })
        } else {
            goButton.alpha = 1
            UIView.animate(withDuration: 0.05, animations: {
                self.goButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                self.goButton.alpha = 0
            }) { _ in
                self.goButton.isHidden = true
            }

        }
    }
    
    
    func onboardingItem(at index: Int) -> OnboardingItemInfo {
      return [
        OnboardingItemInfo(informationImage: UIImage(named: "Bwelcome")!,
                                      title: "Lists Builder...",
                                description: "...Start easily making lists!",
                                   pageIcon: UIImage(),
                                   color: UIColor(named: "OnboardingGray")!,
                                 titleColor: UIColor.black,
                           descriptionColor: UIColor.darkGray,
                           titleFont: UIFont.systemFont(ofSize: 30, weight: .bold),
                            descriptionFont: UIFont.systemFont(ofSize: 17)),
        
        OnboardingItemInfo(informationImage: UIImage(named: "Badd")!,
                   title: "Add a match",
             description: "Matches (aka words) are what Find looks for when you use the list. To make one, just tap the placeholder that says 'Match'!",
                pageIcon: UIImage(named: "1icon")!,
                   color: UIColor(named: "OnboardingGray")!,
              titleColor: UIColor.black,
        descriptionColor: UIColor.darkGray,
        titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
         descriptionFont: UIFont.systemFont(ofSize: 17)),
        
        OnboardingItemInfo(informationImage: UIImage(named: "Breturn")!,
                   title: "Add more matches",
             description: "Once you've typed in your first match, just tap 'next' on the keyboard! Repeat until satisfied.",
                pageIcon: UIImage(named: "2icon")!,
                   color: UIColor(named: "OnboardingGray")!,
              titleColor: UIColor.black,
        descriptionColor: UIColor.darkGray,
        titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
         descriptionFont: UIFont.systemFont(ofSize: 17)),

        OnboardingItemInfo(informationImage: UIImage(named: "Bdelete")!,
                   title: "Delete a match",
             description: "Sometimes you got to delete a match. No feelings hurt, just swipe left and tap 'Delete'!",
                pageIcon: UIImage(named: "3icon")!,
                   color: UIColor(named: "OnboardingGray")!,
              titleColor: UIColor.black,
        descriptionColor: UIColor.darkGray,
        titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
         descriptionFont: UIFont.systemFont(ofSize: 17))
        ][index]
    }

    func onboardingItemsCount() -> Int {
       return 4
    }
}
