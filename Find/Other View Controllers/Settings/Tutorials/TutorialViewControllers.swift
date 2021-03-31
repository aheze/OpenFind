//
//  TutorialViewController.swift
//  Find
//
//  Created by Zheng on 4/1/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit
import SnapKit
import SwiftEntryKit

class GeneralTutorialViewController: UIViewController, PaperOnboardingDelegate, PaperOnboardingDataSource {
    
    @IBOutlet weak var paperOnboarding: PaperOnboarding!
    
    @IBAction func xPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var goButton: UIButton!
    @IBAction func goButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        goButton.layer.cornerRadius = 6
        paperOnboarding.delegate = self
        paperOnboarding.dataSource = self
        

        goButton.alpha = 0
        goButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        goButton.accessibilityLabel = "Continue"
        goButton.accessibilityHint = "Finish tutorial"
    }
    
    func onboardingWillTransitonToIndex(_ index: Int) {
        if index == 3 {
            UIView.animate(withDuration: 0.2, animations: {
                self.goButton.transform = CGAffineTransform.identity
                self.goButton.alpha = 1
            }) { _ in
                UIAccessibility.post(notification: .layoutChanged, argument: self.goButton)
            }
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.goButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                self.goButton.alpha = 0
            })
        }
    }
    
    
    func onboardingItem(at index: Int) -> OnboardingItemInfo {
        let firstDescription = UIAccessibility.isVoiceOverRunning ? "Find text in real life, fast. Swipe up or down on the Page chooser to navigate this tutorial." : LaunchLocalization.swipeToGetStarted 
        return [
            OnboardingItemInfo(informationImage: UIImage(named: "Intro1")!,
                               title: LaunchLocalization.welcomeToFind,
                               description: firstDescription,
                               pageIcon: UIImage(),
                               color: UIColor.systemBackground,
                               titleColor: UIColor.label,
                               descriptionColor: UIColor.secondaryLabel,
                               titleFont: UIFont.systemFont(ofSize: 30, weight: .bold),
                               descriptionFont: UIFont.systemFont(ofSize: 17)),
            
            OnboardingItemInfo(informationImage: UIImage(named: "Intro2")!,
                               title: LaunchLocalization.camera,
                               description: LaunchLocalization.cameraDescription,
                               pageIcon: UIImage(named: "Page1")!,
                               color: UIColor.systemBackground,
                               titleColor: UIColor.label,
                               descriptionColor: UIColor.secondaryLabel,
                               titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
                               descriptionFont: UIFont.systemFont(ofSize: 17)),
            
            OnboardingItemInfo(informationImage: UIImage(named: "Intro3")!,
                               title: LaunchLocalization.photos,
                               description: LaunchLocalization.photosDescription,
                               pageIcon: UIImage(named: "Page2")!,
                               color: UIColor.systemBackground,
                               titleColor: UIColor.label,
                               descriptionColor: UIColor.secondaryLabel,
                               titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
                               descriptionFont: UIFont.systemFont(ofSize: 17)),
            
            OnboardingItemInfo(informationImage: UIImage(named: "Intro4")!,
                               title: LaunchLocalization.lists,
                               description: LaunchLocalization.listsDescription,
                               pageIcon: UIImage(named: "Page3")!,
                               color: UIColor.systemBackground,
                               titleColor: UIColor.label,
                               descriptionColor: UIColor.secondaryLabel,
                               titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
                               descriptionFont: UIFont.systemFont(ofSize: 17))
        ][index]
    }
    func onboardingItemsCount() -> Int {
        return 4
    }
}

class HistoryTutorialViewController: UIViewController, PaperOnboardingDelegate, PaperOnboardingDataSource {
    
    @IBOutlet weak var paperOnboarding: PaperOnboarding!
    
    
    @IBAction func historyXPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var goButton: UIButton!
    @IBAction func histGoButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        goButton.layer.cornerRadius = 6
        paperOnboarding.delegate = self
        paperOnboarding.dataSource = self
        
        goButton.alpha = 0
        goButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        goButton.accessibilityLabel = "Continue"
        goButton.accessibilityHint = "Finish tutorial"
        
    }
    
    func onboardingWillTransitonToIndex(_ index: Int) {
        if index == 3 {
            UIView.animate(withDuration: 0.2, animations: {
                self.goButton.transform = CGAffineTransform.identity
                self.goButton.alpha = 1
            }) { _ in
                UIAccessibility.post(notification: .layoutChanged, argument: self.goButton)
            }
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.goButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                self.goButton.alpha = 0
            })
        }
    }
    
    
    func onboardingItem(at index: Int) -> OnboardingItemInfo {
        return [
            OnboardingItemInfo(informationImage: UIImage(named: "Photos1")!,
                               title: LaunchLocalization.photos,
                               description: LaunchLocalization.photosDescription,
                               pageIcon: UIImage(),
                               color: UIColor.systemBackground,
                               titleColor: UIColor.label,
                               descriptionColor: UIColor.secondaryLabel,
                               titleFont: UIFont.systemFont(ofSize: 30, weight: .bold),
                               descriptionFont: UIFont.systemFont(ofSize: 17)),
            
            OnboardingItemInfo(informationImage: UIImage(named: "Photos2")!,
                               title: PhotosTutorialLocalization.findFromAllPhotos,
                               description: PhotosTutorialLocalization.justTapFind,
                               pageIcon: UIImage(named: "Page1")!,
                               color: UIColor.systemBackground,
                               titleColor: UIColor.label,
                               descriptionColor: UIColor.secondaryLabel,
                               titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
                               descriptionFont: UIFont.systemFont(ofSize: 17)),
            
            OnboardingItemInfo(informationImage: UIImage(named: "Photos3")!,
                               title: PhotosTutorialLocalization.findFromSelectPhotos,
                               description: PhotosTutorialLocalization.tapSelectTapFind,
                               pageIcon: UIImage(named: "Page2")!,
                               color: UIColor.systemBackground,
                               titleColor: UIColor.label,
                               descriptionColor: UIColor.secondaryLabel,
                               titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
                               descriptionFont: UIFont.systemFont(ofSize: 17)),
            
            OnboardingItemInfo(informationImage: UIImage(named: "Photos4")!,
                               title: PhotosTutorialLocalization.cacheYourPhotos,
                               description: PhotosTutorialLocalization.resultsWillAppearInstantly,
                               pageIcon: UIImage(named: "Page3")!,
                               color: UIColor.systemBackground,
                               titleColor: UIColor.label,
                               descriptionColor: UIColor.secondaryLabel,
                               titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
                               descriptionFont: UIFont.systemFont(ofSize: 17))
        ][index]
    }
    
    func onboardingItemsCount() -> Int {
        return 4
    }
}
class ListsTutorialViewController: UIViewController, PaperOnboardingDelegate, PaperOnboardingDataSource {
    
    @IBOutlet weak var paperOnboarding: PaperOnboarding!
    
    
    @IBAction func listsXPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var goButton: UIButton!
    @IBAction func listsGoButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        goButton.layer.cornerRadius = 6
        paperOnboarding.delegate = self
        paperOnboarding.dataSource = self
        
        goButton.alpha = 0
        goButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        goButton.accessibilityLabel = "Continue"
        goButton.accessibilityHint = "Finish tutorial"
    }
    
    func onboardingWillTransitonToIndex(_ index: Int) {
        if index == 3 {
            UIView.animate(withDuration: 0.2, animations: {
                self.goButton.transform = CGAffineTransform.identity
                self.goButton.alpha = 1
            }) { _ in
                UIAccessibility.post(notification: .layoutChanged, argument: self.goButton)
            }
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.goButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                self.goButton.alpha = 0
            })
        }
    }
    
    
    func onboardingItem(at index: Int) -> OnboardingItemInfo {
        return [
            OnboardingItemInfo(informationImage: UIImage(named: "Lists1")!,
                               title: LaunchLocalization.lists,
                               description: LaunchLocalization.listsDescription,
                               pageIcon: UIImage(),
                               color: UIColor.systemBackground,
                               titleColor: UIColor.label,
                               descriptionColor: UIColor.secondaryLabel,
                               titleFont: UIFont.systemFont(ofSize: 30, weight: .bold),
                               descriptionFont: UIFont.systemFont(ofSize: 17)),
            
            OnboardingItemInfo(informationImage: UIImage(named: "Lists2")!,
                               title: ListsTutorialLocalization.makeAList,
                               description: ListsTutorialLocalization.tapThePlusIcon,
                               pageIcon: UIImage(named: "Page1")!,
                               color: UIColor.systemBackground,
                               titleColor: UIColor.label,
                               descriptionColor: UIColor.secondaryLabel,
                               titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
                               descriptionFont: UIFont.systemFont(ofSize: 17)),
            
            OnboardingItemInfo(informationImage: UIImage(named: "Lists3")!,
                               title: ListsTutorialLocalization.addSomeWords,
                               description: ListsTutorialLocalization.findWillLookForThem,
                               pageIcon: UIImage(named: "Page2")!,
                               color: UIColor.systemBackground,
                               titleColor: UIColor.label,
                               descriptionColor: UIColor.secondaryLabel,
                               titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
                               descriptionFont: UIFont.systemFont(ofSize: 17)),
            
            OnboardingItemInfo(informationImage: UIImage(named: "Lists4")!,
                               title: ListsTutorialLocalization.useTheList,
                               description: ListsTutorialLocalization.yourListsWillAppear,
                               pageIcon: UIImage(named: "Page3")!,
                               color: UIColor.systemBackground,
                               titleColor: UIColor.label,
                               descriptionColor: UIColor.secondaryLabel,
                               titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
                               descriptionFont: UIFont.systemFont(ofSize: 17))
        ][index]
    }
    
    func onboardingItemsCount() -> Int {
        return 4
    }
}
class ListsBuilderTutorialViewController: UIViewController, PaperOnboardingDelegate, PaperOnboardingDataSource {
    
    @IBOutlet weak var paperOnboarding: PaperOnboarding!
    
    @IBOutlet weak var goButton: UIButton!
    @IBAction func listsGoButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func listsBuilderXPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        goButton.layer.cornerRadius = 6
        paperOnboarding.delegate = self
        paperOnboarding.dataSource = self
        
        goButton.alpha = 0
        goButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        goButton.accessibilityLabel = "Continue"
        goButton.accessibilityHint = "Finish tutorial"
    }
    
    func onboardingWillTransitonToIndex(_ index: Int) {
        if index == 3 {
            UIView.animate(withDuration: 0.2, animations: {
                self.goButton.transform = CGAffineTransform.identity
                self.goButton.alpha = 1
            }) { _ in
                UIAccessibility.post(notification: .layoutChanged, argument: self.goButton)
            }
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.goButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                self.goButton.alpha = 0
            })
            
        }
    }
    
    
    func onboardingItem(at index: Int) -> OnboardingItemInfo {
        return [
            OnboardingItemInfo(informationImage: UIImage(named: "ListsBuilder1")!,
                               title: ListsBuilderTutorialLocalization.listsBuilder,
                               description: ListsBuilderTutorialLocalization.listsBuilderDescription,
                               pageIcon: UIImage(),
                               color: UIColor.systemBackground,
                               titleColor: UIColor.label,
                               descriptionColor: UIColor.secondaryLabel,
                               titleFont: UIFont.systemFont(ofSize: 30, weight: .bold),
                               descriptionFont: UIFont.systemFont(ofSize: 17)),
            
            OnboardingItemInfo(informationImage: UIImage(named: "ListsBuilder2")!,
                               title: ListsBuilderTutorialLocalization.addAWord,
                               description: ListsBuilderTutorialLocalization.tapThePlaceholder,
                               pageIcon: UIImage(named: "Page1")!,
                               color: UIColor.systemBackground,
                               titleColor: UIColor.label,
                               descriptionColor: UIColor.secondaryLabel,
                               titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
                               descriptionFont: UIFont.systemFont(ofSize: 17)),
            
            OnboardingItemInfo(informationImage: UIImage(named: "ListsBuilder3")!,
                               title: ListsBuilderTutorialLocalization.addMoreWords,
                               description: ListsBuilderTutorialLocalization.justTapNext,
                               pageIcon: UIImage(named: "Page2")!,
                               color: UIColor.systemBackground,
                               titleColor: UIColor.label,
                               descriptionColor: UIColor.secondaryLabel,
                               titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
                               descriptionFont: UIFont.systemFont(ofSize: 17)),
            
            OnboardingItemInfo(informationImage: UIImage(named: "ListsBuilder4")!,
                               title: ListsBuilderTutorialLocalization.deleteAWord,
                               description: ListsBuilderTutorialLocalization.swipeLeftOnIt,
                               pageIcon: UIImage(named: "Page3")!,
                               color: UIColor.systemBackground,
                               titleColor: UIColor.label,
                               descriptionColor: UIColor.secondaryLabel,
                               titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
                               descriptionFont: UIFont.systemFont(ofSize: 17))
        ][index]
    }
    
    func onboardingItemsCount() -> Int {
        return 4
    }
}
