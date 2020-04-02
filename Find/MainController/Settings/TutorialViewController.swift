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
            UIView.animate(withDuration: 0.15, animations: {
                self.goButton.transform = CGAffineTransform.identity
                self.goButton.alpha = 1
            })
        } else {
            goButton.alpha = 1
            UIView.animate(withDuration: 0.15, animations: {
                self.goButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                self.goButton.alpha = 0
            }) { _ in
                self.goButton.isHidden = true
            }

        }
    }
    
    
    func onboardingItem(at index: Int) -> OnboardingItemInfo {
      return [
        OnboardingItemInfo(informationImage: UIImage(named: "Leica Sample")!,
                                      title: "Welcome to Find",
                                description: "Swipe to get started",
                                   pageIcon: UIImage(),
                                   color: UIColor(named: "OnboardingGray")!,
                                 titleColor: UIColor.black,
                           descriptionColor: UIColor.darkGray,
                           titleFont: UIFont.systemFont(ofSize: 30, weight: .bold),
                            descriptionFont: UIFont.systemFont(ofSize: 17)),
        
        OnboardingItemInfo(informationImage: UIImage(named: "Leica Sample")!,
                   title: "What is Find?",
             description: "Find is Command+F for camera. Find words in books, worksheets, nutrition labels... Anywhere as long as there's text!",
                pageIcon: UIImage(named: "1icon")!,
                color: UIColor(named: "OnboardingGray")!,
              titleColor: UIColor.black,
        descriptionColor: UIColor.darkGray,
        titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
         descriptionFont: UIFont.systemFont(ofSize: 17)),
        
        OnboardingItemInfo(informationImage: UIImage(named: "Leica Sample")!,
                   title: "Find words",
             description: "Tap the Search Field at the top of the screen",
                pageIcon: UIImage(named: "2icon")!,
                color: UIColor(named: "OnboardingGray")!,
              titleColor: UIColor.black,
        descriptionColor: UIColor.darkGray,
        titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
         descriptionFont: UIFont.systemFont(ofSize: 17)),

        OnboardingItemInfo(informationImage: UIImage(named: "Leica Sample")!,
                   title: "Take photos",
             description: "Tap the shutter button. Later, you can come back to these and Find from them again and again and again...",
                pageIcon: UIImage(named: "3icon")!,
                   color: UIColor(named: "OnboardingGray")!,
              titleColor: UIColor.black,
        descriptionColor: UIColor.darkGray,
        titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
         descriptionFont: UIFont.systemFont(ofSize: 17)),

       OnboardingItemInfo(informationImage: UIImage(named: "Leica Sample")!,
                  title: "Access the Menu",
            description: "Your History, Lists, and Settings are here. Check it out!",
               pageIcon: UIImage(named: "4icon")!,
                  color: UIColor(named: "OnboardingGray")!,
             titleColor: UIColor.black,
       descriptionColor: UIColor.darkGray,
       titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
        descriptionFont: UIFont.systemFont(ofSize: 17)),
       
       OnboardingItemInfo(informationImage: UIImage(named: "Leica Sample")!,
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
            UIView.animate(withDuration: 0.15, animations: {
                self.goButton.transform = CGAffineTransform.identity
                self.goButton.alpha = 1
            })
        } else {
            goButton.alpha = 1
            UIView.animate(withDuration: 0.15, animations: {
                self.goButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                self.goButton.alpha = 0
            }) { _ in
                self.goButton.isHidden = true
            }

        }
    }
    
    
    func onboardingItem(at index: Int) -> OnboardingItemInfo {
      return [
        OnboardingItemInfo(informationImage: UIImage(named: "Leica Sample")!,
                                      title: "History...",
                                description: "...where all your photos live!",
                                   pageIcon: UIImage(),
                                   color: UIColor(named: "OnboardingGray")!,
                                 titleColor: UIColor.black,
                           descriptionColor: UIColor.darkGray,
                           titleFont: UIFont.systemFont(ofSize: 30, weight: .bold),
                            descriptionFont: UIFont.systemFont(ofSize: 17)),
        
        OnboardingItemInfo(informationImage: UIImage(named: "Leica Sample")!,
                   title: "Select photos",
             description: "Tap the select button, and the History Controls will pop up!",
                pageIcon: UIImage(named: "1icon")!,
                   color: UIColor(named: "OnboardingGray")!,
              titleColor: UIColor.black,
        descriptionColor: UIColor.darkGray,
        titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
         descriptionFont: UIFont.systemFont(ofSize: 17)),
        
        OnboardingItemInfo(informationImage: UIImage(named: "Leica Sample")!,
                   title: "Find from History",
             description: "Select a few photos, then tap the Find icon",
                pageIcon: UIImage(named: "2icon")!,
                   color: UIColor(named: "OnboardingGray")!,
              titleColor: UIColor.black,
        descriptionColor: UIColor.darkGray,
        titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
         descriptionFont: UIFont.systemFont(ofSize: 17)),

        OnboardingItemInfo(informationImage: UIImage(named: "Leica Sample")!,
                   title: "Cache photos",
             description: "Find uses OCR to search in your photos, but because it is often time consuming, you have the option to pre-search (aka Cache) them. Once a photo is cached, results will appear immediately when you find in it!",
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
            UIView.animate(withDuration: 0.15, animations: {
                self.goButton.transform = CGAffineTransform.identity
                self.goButton.alpha = 1
            })
        } else {
            goButton.alpha = 1
            UIView.animate(withDuration: 0.15, animations: {
                self.goButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                self.goButton.alpha = 0
            }) { _ in
                self.goButton.isHidden = true
            }

        }
    }
    
    
    func onboardingItem(at index: Int) -> OnboardingItemInfo {
      return [
        OnboardingItemInfo(informationImage: UIImage(named: "Leica Sample")!,
                                      title: "Lists...",
                                description: "...find multiple words at the same time!",
                                   pageIcon: UIImage(),
                                   color: UIColor(named: "OnboardingGray")!,
                                 titleColor: UIColor.black,
                           descriptionColor: UIColor.darkGray,
                           titleFont: UIFont.systemFont(ofSize: 30, weight: .bold),
                            descriptionFont: UIFont.systemFont(ofSize: 17)),
        
        OnboardingItemInfo(informationImage: UIImage(named: "Leica Sample")!,
                   title: "Make a list",
             description: "Tap the Add button",
                pageIcon: UIImage(named: "1icon")!,
                   color: UIColor(named: "OnboardingGray")!,
              titleColor: UIColor.black,
        descriptionColor: UIColor.darkGray,
        titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
         descriptionFont: UIFont.systemFont(ofSize: 17)),
        
        OnboardingItemInfo(informationImage: UIImage(named: "Leica Sample")!,
                   title: "Add some matches",
             description: "Matches are the words that Find searches for when you use the list",
                pageIcon: UIImage(named: "2icon")!,
                   color: UIColor(named: "OnboardingGray")!,
              titleColor: UIColor.black,
        descriptionColor: UIColor.darkGray,
        titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
         descriptionFont: UIFont.systemFont(ofSize: 17)),

        OnboardingItemInfo(informationImage: UIImage(named: "Leica Sample")!,
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
