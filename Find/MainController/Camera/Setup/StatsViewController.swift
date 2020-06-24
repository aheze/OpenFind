//
//  StatsViewController.swift
//  Find
//
//  Created by Zheng on 3/30/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit
import SwiftEntryKit

class StatsViewController: UIViewController, UpdateMatchesNumberStats {
    
    
    func update(to: Int) {
        DispatchQueue.main.async {
            let boldAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .bold)]
            let regularAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .regular)]
            
            let boldText = NSAttributedString(string: "\(to)", attributes: boldAttribute)
            
            let matchesFoundCurrently = NSLocalizedString("matchesFoundCurrently", comment: "StatsViewController def=matches found currently")
            
            let regularText = NSAttributedString(string: " \(matchesFoundCurrently)", attributes: regularAttribute)
            let newString = NSMutableAttributedString()
            
            newString.append(boldText)
            newString.append(regularText)
            self.currentlyHowManyMatches.attributedText = newString
        }
    }
     
    @IBAction func xButtonPressed(_ sender: Any) {
        SwiftEntryKit.dismiss()
    }
    
    @IBOutlet weak var justForFun: UILabel!
    
    
    @IBOutlet weak var currentlyHowManyMatches: UILabel!
    
    @IBOutlet weak var currentSearchingForTheseWords: UILabel!
    
    @IBOutlet weak var cachesSinceFirstD: UILabel!
    @IBOutlet weak var helpPressCount: UILabel!
    @IBOutlet weak var listsCreateCount: UILabel!
    
    @IBOutlet weak var customizedSettings: UILabel!
    @IBOutlet weak var leftFeedback: UILabel!
    
    @IBOutlet weak var viewStatsStatus: UILabel!
    
    let defaults = UserDefaults.standard
    
    var arrayOfEmoji = ["😀", "😃", "😁", "😄", "😌", "😜", "😛", "😏", "🤔", "🥴", "🥱", "😅", "😂", "🤣", "🙃", "😉", "😋", "🤪", "😝", "🤓", "😎", "🤩"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let randomEmoji = arrayOfEmoji.randomElement() {
            let justForFunStats = NSLocalizedString("justForFunStats", comment: "StatsViewController def=Just for fun")
//            justForFun.text = "(Just for fun \(randomEmoji))"
            justForFun.text = "(\(justForFunStats) \(randomEmoji))"
        }
        
        let cacheCount = defaults.integer(forKey: "cacheCountTotal")
        let helpCount = defaults.integer(forKey: "helpPressCount")
        let listsCount = defaults.integer(forKey: "listsCreateCount")
        
        let settCustomized = defaults.bool(forKey: "customizedSettingsBool")
        let feedbacked = defaults.bool(forKey: "feedbackedAlready")
        
        var cacheS = "s"
        var helpS = "s"
        var listsS = "s"
        
        let photosPluralLoc = NSLocalizedString("photosPluralLoc", comment: "StatsViewController def=photos")
        let timesPluralLoc = NSLocalizedString("timesPluralLoc", comment: "StatsViewController def=times")
        let listsPluralLoc = NSLocalizedString("listsPluralLoc", comment: "StatsViewController def=lists")
        
        var photosPlural = photosPluralLoc
        var timesPlural = timesPluralLoc
        var listsPlural = listsPluralLoc
        
        if cacheCount == 1 {
            let photoSingularLoc = NSLocalizedString("photosSingularLoc", comment: "StatsViewController def=photo")
            photosPlural = photoSingularLoc
            
        }
        if helpCount == 1 {
            let timeSingularLoc = NSLocalizedString("timeSingularLoc", comment: "StatsViewController def=time")
            timesPlural = timeSingularLoc
            
        }
        if listsCount == 1 {
            let listSingularLoc = NSLocalizedString("listSingularLoc", comment: "StatsViewController def=list")
            listsPlural = listSingularLoc
            
        }
        
//        if cacheCount == 1 { cacheS = "" }
//        if helpCount == 1 { helpS = "" }
//        if listsCount == 1 { listsS = "" }
        
        
        let boldAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .bold)]
        let regularAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .regular)]
        
        let cacheBold = NSAttributedString(string: "\(cacheCount)", attributes: boldAttribute)
//        let cacheRegular = NSAttributedString(string: " photo\(cacheS) cached since you first downloaded Find", attributes: regularAttribute)
        let cacheRegular = NSAttributedString(string: " \(photosPlural) cached since you first downloaded Find", attributes: regularAttribute)
        let cacheString = NSMutableAttributedString()
        cacheString.append(cacheBold)
        cacheString.append(cacheRegular)
        cachesSinceFirstD.attributedText = cacheString
        
        
        let helpPressed = NSLocalizedString("helpPressed", comment: "StatsViewController def=Help pressed")
        
        let helpRegular1 = NSAttributedString(string: helpPressed, attributes: regularAttribute)
        let helpBold = NSAttributedString(string: " \(helpCount)", attributes: boldAttribute)
        
        let sinceYouFirstDownloadedFind = NSLocalizedString("sinceYouFirstDownloadedFind", comment: "StatsViewController def=since you first downloaded Find")
        
        let helpRegular2 = NSAttributedString(string: " \(timesPlural) \(sinceYouFirstDownloadedFind)", attributes: regularAttribute)
        let helpString = NSMutableAttributedString()
        helpString.append(helpRegular1)
        helpString.append(helpBold)
        helpString.append(helpRegular2)
        helpPressCount.attributedText = helpString
        
        let created = NSLocalizedString("created", comment: "StatsViewController def=created")
        
        let listsBold = NSAttributedString(string: "\(listsCount)", attributes: boldAttribute)
        let listsRegular = NSAttributedString(string: " \(listsPlural) \(created) \(sinceYouFirstDownloadedFind)", attributes: regularAttribute)
        let listsString = NSMutableAttributedString()
        listsString.append(listsBold)
        listsString.append(listsRegular)
        listsCreateCount.attributedText = listsString
        
        let customizedSettingsStatus = NSLocalizedString("customizedSettingsStatus", comment: "StatsViewController def=Customized Settings Status")
        let leftFeedbackStatus = NSLocalizedString("leftFeedbackStatus", comment: "StatsViewController def=Left Feedback Status")
        let viewedStatsStatus = NSLocalizedString("viewedStatsStatus", comment: "StatsViewController def=Viewed Stats Status")
        
        let settRegular = NSAttributedString(string: "\(customizedSettingsStatus): ", attributes: regularAttribute)
        let settBold = NSAttributedString(string: settCustomized.toLocString(), attributes: boldAttribute)
        let settString = NSMutableAttributedString()
        settString.append(settRegular)
        settString.append(settBold)
        customizedSettings.attributedText = settString
        
        let feedRegular = NSAttributedString(string: "\(leftFeedbackStatus): ", attributes: regularAttribute)
        let feedBold = NSAttributedString(string: feedbacked.toLocString(), attributes: boldAttribute)
        let feedString = NSMutableAttributedString()
        feedString.append(feedRegular)
        feedString.append(feedBold)
        leftFeedback.attributedText = feedString
        
        let viewStatRegular = NSAttributedString(string: "\(viewedStatsStatus): ", attributes: regularAttribute)
        let boolTrue = true
        let viewStatBold = NSAttributedString(string: boolTrue.toLocString(), attributes: boldAttribute)
        let viewStatString = NSMutableAttributedString()
        viewStatString.append(viewStatRegular)
        viewStatString.append(viewStatBold)
        viewStatsStatus.attributedText = viewStatString
        
    }
    
    
}

extension Bool {
    func toLocString() -> String {
        let locBoolTrue = NSLocalizedString("locBoolTrue", comment: "MultipurposeExtension def=true")
        let locBoolFalse = NSLocalizedString("locBoolFalse", comment: "MultipurposeExtension def=false")
        
        if self == true {
            return locBoolTrue
        } else {
            return locBoolFalse
        }
    }
}
