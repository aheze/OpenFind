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
            let regularText = NSAttributedString(string: " matches found currently", attributes: regularAttribute)
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
            justForFun.text = "(Just for fun \(randomEmoji))"
        }
        
        let cacheCount = defaults.integer(forKey: "cacheCountTotal")
        let helpCount = defaults.integer(forKey: "helpPressCount")
        let listsCount = defaults.integer(forKey: "listsCreateCount")
        
        let settCustomized = defaults.bool(forKey: "customizedSettingsBool")
        let feedbacked = defaults.bool(forKey: "feedbackedAlready")
        
        var cacheS = "s"
        var helpS = "s"
        var listsS = "s"
        
        if cacheCount == 1 { cacheS = "" }
        if helpCount == 1 { helpS = "" }
        if listsCount == 1 { listsS = "" }
        
        
        let boldAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .bold)]
        let regularAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .regular)]
        
        let cacheBold = NSAttributedString(string: "\(cacheCount)", attributes: boldAttribute)
        let cacheRegular = NSAttributedString(string: " photo\(cacheS) cached since you first downloaded Find", attributes: regularAttribute)
        let cacheString = NSMutableAttributedString()
        cacheString.append(cacheBold)
        cacheString.append(cacheRegular)
        cachesSinceFirstD.attributedText = cacheString
        
        
    
        let helpRegular1 = NSAttributedString(string: "Help pressed", attributes: regularAttribute)
        let helpBold = NSAttributedString(string: " \(helpCount)", attributes: boldAttribute)
        let helpRegular2 = NSAttributedString(string: " time\(helpS) since you first downloaded Find", attributes: regularAttribute)
        let helpString = NSMutableAttributedString()
        helpString.append(helpRegular1)
        helpString.append(helpBold)
        helpString.append(helpRegular2)
        helpPressCount.attributedText = helpString
        
        
        let listsBold = NSAttributedString(string: "\(listsCount)", attributes: boldAttribute)
        let listsRegular = NSAttributedString(string: " list\(listsS) created since you first downloaded Find", attributes: regularAttribute)
        let listsString = NSMutableAttributedString()
        listsString.append(listsBold)
        listsString.append(listsRegular)
        listsCreateCount.attributedText = listsString
        
        let settRegular = NSAttributedString(string: "Customized Settings Status: ", attributes: regularAttribute)
        let settBold = NSAttributedString(string: "\(settCustomized)", attributes: boldAttribute)
        let settString = NSMutableAttributedString()
        settString.append(settRegular)
        settString.append(settBold)
        customizedSettings.attributedText = settString
        
        let feedRegular = NSAttributedString(string: "Left Feedback Status: ", attributes: regularAttribute)
        let feedBold = NSAttributedString(string: "\(feedbacked)", attributes: boldAttribute)
        let feedString = NSMutableAttributedString()
        feedString.append(feedRegular)
        feedString.append(feedBold)
        leftFeedback.attributedText = feedString
        
        let viewStatRegular = NSAttributedString(string: "Viewed Stats Status: ", attributes: regularAttribute)
        let viewStatBold = NSAttributedString(string: "true", attributes: boldAttribute)
        let viewStatString = NSMutableAttributedString()
        viewStatString.append(viewStatRegular)
        viewStatString.append(viewStatBold)
        viewStatsStatus.attributedText = viewStatString
        
    }
    
    
}
