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
    
    let loc = LaunchLocalization()
    
    @IBOutlet weak var paperOnboarding: PaperOnboarding!
    
        
    @IBAction func xPressed(_ sender: Any) {
        SwiftEntryKit.dismiss()
    }
        
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
        
//        goButton.isHidden = true
        goButton.alpha = 0
        goButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
    func onboardingWillTransitonToIndex(_ index: Int) {
        if index == 6 {
//            goButton.isHidden = false
//            goButton.alpha = 0
            UIView.animate(withDuration: 0.2, animations: {
                self.goButton.transform = CGAffineTransform.identity
                self.goButton.alpha = 1
            })
        } else {
//            goButton.alpha = 1
            UIView.animate(withDuration: 0.2, animations: {
                self.goButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                self.goButton.alpha = 0
            })

        }
    }
    
    
    func onboardingItem(at index: Int) -> OnboardingItemInfo {
      return [
        OnboardingItemInfo(informationImage: UIImage(named: "Swelcome")!,
                           title: loc.welcomeToFind,
                                description: loc.swipeToGetStarted,
                                   pageIcon: UIImage(),
                                   color: UIColor(named: "OnboardingGray")!,
                                 titleColor: UIColor.black,
                           descriptionColor: UIColor.darkGray,
                           titleFont: UIFont.systemFont(ofSize: 30, weight: .bold),
                            descriptionFont: UIFont.systemFont(ofSize: 17)),
        
        OnboardingItemInfo(informationImage: UIImage(named: "Swhatis")!,
                   title: loc.whatIsFind,
             description: loc.findIsCommandFForCamera,
                pageIcon: UIImage(named: "1icon")!,
                color: UIColor(named: "OnboardingGray")!,
              titleColor: UIColor.black,
        descriptionColor: UIColor.darkGray,
        titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
         descriptionFont: UIFont.systemFont(ofSize: 17)),
        
        OnboardingItemInfo(informationImage: UIImage(named: "Ssearchfield")!,
                   title: loc.findWords,
             description: loc.tapSearchField,
                pageIcon: UIImage(named: "2icon")!,
                color: UIColor(named: "OnboardingGray")!,
              titleColor: UIColor.black,
        descriptionColor: UIColor.darkGray,
        titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
         descriptionFont: UIFont.systemFont(ofSize: 17)),

        OnboardingItemInfo(informationImage: UIImage(named: "Slists")!,
        title: loc.lists,
        description: loc.makeLists,
        pageIcon: UIImage(named: "3icon")!,
        color: UIColor(named: "OnboardingGray")!,
        titleColor: UIColor.black,
        descriptionColor: UIColor.darkGray,
        titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
        descriptionFont: UIFont.systemFont(ofSize: 17)),
        
        
        OnboardingItemInfo(informationImage: UIImage(named: "Sshutter")!,
                           title: loc.takePhotos,
                           description: loc.tapShutterButton,
                           pageIcon: UIImage(named: "4icon")!,
                           color: UIColor(named: "OnboardingGray")!,
                           titleColor: UIColor.black,
                           descriptionColor: UIColor.darkGray,
                           titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
                           descriptionFont: UIFont.systemFont(ofSize: 17)),
        
        OnboardingItemInfo(informationImage: UIImage(named: "Smenu")!,
                           title: loc.accessMenu,
                           description: loc.yourPhotosListsAndSettingsHere,
                           pageIcon: UIImage(named: "5icon")!,
                           color: UIColor(named: "OnboardingGray")!,
                           titleColor: UIColor.black,
                           descriptionColor: UIColor.darkGray,
                           titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
                           descriptionFont: UIFont.systemFont(ofSize: 17)),
        
        OnboardingItemInfo(informationImage: UIImage(named: "Sjitter")!,
                           title: loc.beforeYouStart,
                           description: loc.ensureAccuracy,
                           pageIcon: UIImage(named: "6icon")!,
                           color: UIColor(named: "OnboardingGray")!,
                           titleColor: UIColor.black,
                           descriptionColor: UIColor.darkGray,
                           titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
                           descriptionFont: UIFont.systemFont(ofSize: 17))
        ][index]
    }
    func onboardingItemsCount() -> Int {
       return 7
    }
}

class HistoryTutorialViewController: UIViewController, PaperOnboardingDelegate, PaperOnboardingDataSource {
//    let getStartedButton = UIButton()
    
    let loc = HistoryTutorialLocalization()
    
    @IBOutlet weak var paperOnboarding: PaperOnboarding!
    
    
    @IBAction func historyXPressed(_ sender: Any) {
        SwiftEntryKit.dismiss()
    }
    
    @IBOutlet weak var goButton: UIButton!
    @IBAction func histGoButtonPressed(_ sender: Any) {
        SwiftEntryKit.dismiss()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        goButton.layer.cornerRadius = 6
        paperOnboarding.delegate = self
        paperOnboarding.dataSource = self
        
//        goButton.isHidden = true
        goButton.alpha = 0
        goButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        
    }
    
    func onboardingWillTransitonToIndex(_ index: Int) {
        if index == 3 {
//            goButton.alpha = 0
//            goButton.isHidden = false
            UIView.animate(withDuration: 0.2, animations: {
                self.goButton.transform = CGAffineTransform.identity
                self.goButton.alpha = 1
            })
        } else {
//            goButton.alpha = 1
            UIView.animate(withDuration: 0.2, animations: {
                self.goButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                self.goButton.alpha = 0
            })
        }
    }
    
    
    func onboardingItem(at index: Int) -> OnboardingItemInfo {
      return [
        OnboardingItemInfo(informationImage: UIImage(named: "Hwelcome")!,
                           title: loc.welcomeToPhotos,
                           description: loc.photosFindAgainAndAgain,
                                   pageIcon: UIImage(),
                                   color: UIColor(named: "OnboardingGray")!,
                                 titleColor: UIColor.black,
                           descriptionColor: UIColor.darkGray,
                           titleFont: UIFont.systemFont(ofSize: 30, weight: .bold),
                            descriptionFont: UIFont.systemFont(ofSize: 17)),
        
        OnboardingItemInfo(informationImage: UIImage(named: "Hselect")!,
                           title: loc.selectPhotos,
                           description: loc.tapSelectButtonAndPopUp,
                pageIcon: UIImage(named: "1icon")!,
                   color: UIColor(named: "OnboardingGray")!,
              titleColor: UIColor.black,
        descriptionColor: UIColor.darkGray,
        titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
         descriptionFont: UIFont.systemFont(ofSize: 17)),
        
        OnboardingItemInfo(informationImage: UIImage(named: "Hfind")!,
                           title: loc.findFromPhotos,
                           description: loc.selectAFewPhotos,
                pageIcon: UIImage(named: "2icon")!,
                   color: UIColor(named: "OnboardingGray")!,
              titleColor: UIColor.black,
        descriptionColor: UIColor.darkGray,
        titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
         descriptionFont: UIFont.systemFont(ofSize: 17)),

        OnboardingItemInfo(informationImage: UIImage(named: "Hcache")!,
                           title: loc.cachePhotos,
                           description: loc.cachingPhotos,
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

    let loc = ListsTutorialLocalization()
    
    @IBOutlet weak var paperOnboarding: PaperOnboarding!
    
    
    @IBAction func listsXPressed(_ sender: Any) {
        SwiftEntryKit.dismiss()
    }
    
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
        
//        goButton.isHidden = true
        goButton.alpha = 0
        goButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
    func onboardingWillTransitonToIndex(_ index: Int) {
        if index == 3 {
//            goButton.alpha = 0
//            goButton.isHidden = false
            UIView.animate(withDuration: 0.2, animations: {
                self.goButton.transform = CGAffineTransform.identity
                self.goButton.alpha = 1
            })
        } else {
//            goButton.alpha = 1
            UIView.animate(withDuration: 0.2, animations: {
                self.goButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                self.goButton.alpha = 0
            })

        }
    }
    
    
    func onboardingItem(at index: Int) -> OnboardingItemInfo {
      return [
        OnboardingItemInfo(informationImage: UIImage(named: "Lwelcome")!,
                           title: loc.welcomeToLists,
                           description: loc.findMultipleWords,
                                   pageIcon: UIImage(),
                                   color: UIColor(named: "OnboardingGray")!,
                                 titleColor: UIColor.black,
                           descriptionColor: UIColor.darkGray,
                           titleFont: UIFont.systemFont(ofSize: 30, weight: .bold),
                            descriptionFont: UIFont.systemFont(ofSize: 17)),
        
        OnboardingItemInfo(informationImage: UIImage(named: "LaddList")!,
                           title: loc.makeAList,
                           description: loc.tapTheAddButton,
                pageIcon: UIImage(named: "1icon")!,
                   color: UIColor(named: "OnboardingGray")!,
              titleColor: UIColor.black,
        descriptionColor: UIColor.darkGray,
        titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
         descriptionFont: UIFont.systemFont(ofSize: 17)),
        
        OnboardingItemInfo(informationImage: UIImage(named: "LaddMatch")!,
                           title: loc.addSomeMatches,
                           description: loc.findSearchesForMatches,
                pageIcon: UIImage(named: "2icon")!,
                   color: UIColor(named: "OnboardingGray")!,
              titleColor: UIColor.black,
        descriptionColor: UIColor.darkGray,
        titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
         descriptionFont: UIFont.systemFont(ofSize: 17)),

        OnboardingItemInfo(informationImage: UIImage(named: "Luse")!,
                           title: loc.useTheList,
                           description: loc.yourListsWillAppear,
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

    let loc = ListsBuilderTutorialLocalization()
    
    @IBOutlet weak var paperOnboarding: PaperOnboarding!
    
    @IBOutlet weak var goButton: UIButton!
    @IBAction func listsGoButtonPressed(_ sender: Any) {
        SwiftEntryKit.dismiss()
    }
    
    
    @IBAction func listsBuilderXPressed(_ sender: Any) {
        SwiftEntryKit.dismiss()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("TUTO")
        
        goButton.layer.cornerRadius = 6
        paperOnboarding.delegate = self
        paperOnboarding.dataSource = self
        
//        goButton.isHidden = true
        goButton.alpha = 0
        goButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
    func onboardingWillTransitonToIndex(_ index: Int) {
        if index == 3 {
//            goButton.alpha = 0
//            goButton.isHidden = false
            UIView.animate(withDuration: 0.2, animations: {
                self.goButton.transform = CGAffineTransform.identity
                self.goButton.alpha = 1
            })
        } else {
//            goButton.alpha = 1
            UIView.animate(withDuration: 0.2, animations: {
                self.goButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                self.goButton.alpha = 0
            })

        }
    }
    
    
    func onboardingItem(at index: Int) -> OnboardingItemInfo {
      return [
        OnboardingItemInfo(informationImage: UIImage(named: "Bwelcome")!,
                           title: loc.welcomeToListsBuilder,
                           description: loc.startEasilyMakingLists,
                                   pageIcon: UIImage(),
                                   color: UIColor(named: "OnboardingGray")!,
                                 titleColor: UIColor.black,
                           descriptionColor: UIColor.darkGray,
                           titleFont: UIFont.systemFont(ofSize: 30, weight: .bold),
                            descriptionFont: UIFont.systemFont(ofSize: 17)),
        
        OnboardingItemInfo(informationImage: UIImage(named: "Badd")!,
                           title: loc.addAMatch,
                           description: loc.matchesAreWhatFindLooksFor,
                pageIcon: UIImage(named: "1icon")!,
                   color: UIColor(named: "OnboardingGray")!,
              titleColor: UIColor.black,
        descriptionColor: UIColor.darkGray,
        titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
         descriptionFont: UIFont.systemFont(ofSize: 17)),
        
        OnboardingItemInfo(informationImage: UIImage(named: "Breturn")!,
                           title: loc.addMoreMatches,
                           description: loc.onceYouveTypedInYourFirstMatch,
                pageIcon: UIImage(named: "2icon")!,
                   color: UIColor(named: "OnboardingGray")!,
              titleColor: UIColor.black,
        descriptionColor: UIColor.darkGray,
        titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
         descriptionFont: UIFont.systemFont(ofSize: 17)),

        OnboardingItemInfo(informationImage: UIImage(named: "Bdelete")!,
                           title: loc.deleteAMatch,
                           description: loc.sometimesYouGotToDeleteAMatch,
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
