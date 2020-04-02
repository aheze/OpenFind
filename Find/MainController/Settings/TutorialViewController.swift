//
//  TutorialViewController.swift
//  Find
//
//  Created by Zheng on 4/1/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit
import paper_onboarding
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
        if index == 4 {
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
                                   pageIcon: UIImage(named: "1icon")!,
                                   color: #colorLiteral(red: 0.8999999762, green: 0.8999999762, blue: 0.8999999762, alpha: 1),
                                 titleColor: UIColor.black,
                           descriptionColor: UIColor.darkGray,
                           titleFont: UIFont.systemFont(ofSize: 30, weight: .bold),
                            descriptionFont: UIFont.systemFont(ofSize: 17)),
        
        OnboardingItemInfo(informationImage: UIImage(named: "Leica Sample")!,
                   title: "What is Find?",
             description: "Find is Command+F for camera. Find words in books, worksheets, nutrition labels... Anywhere as long as there's text!",
                pageIcon: UIImage(named: "2icon")!,
                   color: #colorLiteral(red: 0.8899999857, green: 0.8899999857, blue: 0.8899999857, alpha: 1),
              titleColor: UIColor.black,
        descriptionColor: UIColor.darkGray,
        titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
         descriptionFont: UIFont.systemFont(ofSize: 17)),
        
        OnboardingItemInfo(informationImage: UIImage(named: "Leica Sample")!,
                   title: "Find words",
             description: "Tap the Search Field at the top of the screen",
                pageIcon: UIImage(named: "3icon")!,
                   color: #colorLiteral(red: 0.8799999952, green: 0.8799999952, blue: 0.8799999952, alpha: 1),
              titleColor: UIColor.black,
        descriptionColor: UIColor.darkGray,
        titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
         descriptionFont: UIFont.systemFont(ofSize: 17)),

        OnboardingItemInfo(informationImage: UIImage(named: "Leica Sample")!,
                   title: "Take photos",
             description: "Tap the shutter button. Later, you can come back to these and Find from them again and again and again...",
                pageIcon: UIImage(named: "4icon")!,
                   color: #colorLiteral(red: 0.8700000048, green: 0.8700000048, blue: 0.8700000048, alpha: 1),
              titleColor: UIColor.black,
        descriptionColor: UIColor.darkGray,
        titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
         descriptionFont: UIFont.systemFont(ofSize: 17)),

       OnboardingItemInfo(informationImage: UIImage(named: "Leica Sample")!,
                  title: "Access the Menu",
            description: "Your History, Lists, and Settings are here. Check it out!",
               pageIcon: UIImage(named: "5icon")!,
                  color: #colorLiteral(red: 0.8600000143, green: 0.8600000143, blue: 0.8600000143, alpha: 1),
             titleColor: UIColor.black,
       descriptionColor: UIColor.darkGray,
       titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
        descriptionFont: UIFont.systemFont(ofSize: 17))
        ][index]
    }

    func onboardingItemsCount() -> Int {
       return 5
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
                                      title: "Welcome to Find",
                                description: "Swipe to get started",
                                   pageIcon: UIImage(named: "1icon")!,
                                   color: #colorLiteral(red: 0.8999999762, green: 0.8999999762, blue: 0.8999999762, alpha: 1),
                                 titleColor: UIColor.black,
                           descriptionColor: UIColor.darkGray,
                           titleFont: UIFont.systemFont(ofSize: 30, weight: .bold),
                            descriptionFont: UIFont.systemFont(ofSize: 17)),
        
        OnboardingItemInfo(informationImage: UIImage(named: "Leica Sample")!,
                   title: "What is Find?",
             description: "Find is Command+F for camera. Find words in books, worksheets, nutrition labels... Anywhere as long as there's text!",
                pageIcon: UIImage(named: "2icon")!,
                   color: #colorLiteral(red: 0.8899999857, green: 0.8899999857, blue: 0.8899999857, alpha: 1),
              titleColor: UIColor.black,
        descriptionColor: UIColor.darkGray,
        titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
         descriptionFont: UIFont.systemFont(ofSize: 17)),
        
        OnboardingItemInfo(informationImage: UIImage(named: "Leica Sample")!,
                   title: "Find words",
             description: "Tap the Search Field at the top of the screen",
                pageIcon: UIImage(named: "3icon")!,
                   color: #colorLiteral(red: 0.8799999952, green: 0.8799999952, blue: 0.8799999952, alpha: 1),
              titleColor: UIColor.black,
        descriptionColor: UIColor.darkGray,
        titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
         descriptionFont: UIFont.systemFont(ofSize: 17)),

        OnboardingItemInfo(informationImage: UIImage(named: "Leica Sample")!,
                   title: "Take photos",
             description: "Tap the shutter button. Later, you can come back to these and Find from them again and again and again...",
                pageIcon: UIImage(named: "4icon")!,
                   color: #colorLiteral(red: 0.8700000048, green: 0.8700000048, blue: 0.8700000048, alpha: 1),
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
                                      title: "Welcome to Find",
                                description: "Swipe to get started",
                                   pageIcon: UIImage(named: "1icon")!,
                                   color: #colorLiteral(red: 0.8999999762, green: 0.8999999762, blue: 0.8999999762, alpha: 1),
                                 titleColor: UIColor.black,
                           descriptionColor: UIColor.darkGray,
                           titleFont: UIFont.systemFont(ofSize: 30, weight: .bold),
                            descriptionFont: UIFont.systemFont(ofSize: 17)),
        
        OnboardingItemInfo(informationImage: UIImage(named: "Leica Sample")!,
                   title: "What is Find?",
             description: "Find is Command+F for camera. Find words in books, worksheets, nutrition labels... Anywhere as long as there's text!",
                pageIcon: UIImage(named: "2icon")!,
                   color: #colorLiteral(red: 0.8899999857, green: 0.8899999857, blue: 0.8899999857, alpha: 1),
              titleColor: UIColor.black,
        descriptionColor: UIColor.darkGray,
        titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
         descriptionFont: UIFont.systemFont(ofSize: 17)),
        
        OnboardingItemInfo(informationImage: UIImage(named: "Leica Sample")!,
                   title: "Find words",
             description: "Tap the Search Field at the top of the screen",
                pageIcon: UIImage(named: "3icon")!,
                   color: #colorLiteral(red: 0.8799999952, green: 0.8799999952, blue: 0.8799999952, alpha: 1),
              titleColor: UIColor.black,
        descriptionColor: UIColor.darkGray,
        titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
         descriptionFont: UIFont.systemFont(ofSize: 17)),

        OnboardingItemInfo(informationImage: UIImage(named: "Leica Sample")!,
                   title: "Take photos",
             description: "Tap the shutter button. Later, you can come back to these and Find from them again and again and again...",
                pageIcon: UIImage(named: "4icon")!,
                   color: #colorLiteral(red: 0.8700000048, green: 0.8700000048, blue: 0.8700000048, alpha: 1),
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
