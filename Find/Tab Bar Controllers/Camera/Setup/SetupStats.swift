//
//  SetupButtons.swift
//  Find
//
//  Created by Andrew on 11/11/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

extension StatsViewController {
    func setupNavigationBar() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithDefaultBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navBarAppearance.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        
        navigationController?.navigationBar.barTintColor = UIColor.black.withAlphaComponent(0.9)
        navigationController?.navigationBar.tintColor = UIColor.white
    }
}

extension CameraViewController {
    
    func tappedOnStats() {
        
        let boldAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .bold)]
        let regularAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .regular)]
        
        let spaceMatchesFoundCurrently = NSLocalizedString("spaceMatchesFoundCurrently", comment: "Stats def= matches found currently")
        
        let boldText = NSAttributedString(string: "\(currentNumberOfMatches)", attributes: boldAttribute)
        let regularText = NSAttributedString(string: spaceMatchesFoundCurrently, attributes: regularAttribute)
        let newString = NSMutableAttributedString()
        newString.append(boldText)
        newString.append(regularText)
        statsNavController.viewController.currentlyHowManyMatchesText = newString
        
        let currentlySearchingFor = NSLocalizedString("currentlySearchingFor", comment: "Stats def=Currently searching for")
        
        if allowSearch == true {
            var wordsFinding = [String]()
            for list in stringToList.keys {
                wordsFinding.append(list)
            }
            
            var finalMatchesString = ""
            
            switch wordsFinding.count {
             case 0:
                let noWords = NSLocalizedString("noWords", comment: "Stats def=[no words]")
                finalMatchesString = noWords
             case 1:
                let quotexquote = NSLocalizedString("quote %@ quote", comment: "Stats def=“x”")
                let string = String.localizedStringWithFormat(quotexquote, wordsFinding[0])
                finalMatchesString = string
             case 2:
                let quotexquoteSpaceAndquotexquote = NSLocalizedString("quote %@ quoteSpaceAndquote %@ quote", comment: "Stats def=“x” and “x”")
                let string = String.localizedStringWithFormat(quotexquoteSpaceAndquotexquote, wordsFinding[0], wordsFinding[1])
                finalMatchesString = string
                
             default:
                for (index, message) in wordsFinding.enumerated() {
                    if index != wordsFinding.count - 1 {
                        let quotexquoteCommaSpace = NSLocalizedString("quote %@ quoteCommaSpace", comment: "Stats def=\"x\", ")
                        let string = String.localizedStringWithFormat(quotexquoteCommaSpace, message)
                        finalMatchesString.append(string)
                    } else {
                        let spaceAndSpacequotexquote = NSLocalizedString("spaceAndSpacequote %@ quote", comment: "Stats def= and \"x\"")
                        let string = String.localizedStringWithFormat(spaceAndSpacequotexquote, message)
                        finalMatchesString.append(string)
                    }
                }
             }
            
            let thisWordColon = NSLocalizedString("thisWord", comment: "Stats def=this word")
            let theseWordsColon = NSLocalizedString("theseWords", comment: "Stats def=these words")
            
            
            var thisWord = thisWordColon
            if wordsFinding.count != 1 {
                thisWord = theseWordsColon
            }
            
            let regularMatchesText = NSAttributedString(string: "\(currentlySearchingFor) \(thisWord): ", attributes: regularAttribute)
            let boldMatchesText = NSAttributedString(string: finalMatchesString, attributes: boldAttribute)
            
            let newMatches = NSMutableAttributedString()
            newMatches.append(regularMatchesText)
            newMatches.append(boldMatchesText)
            statsNavController.viewController.currentSearchingForTheseWordsText = newMatches
            
        } else {
            let regularMatchesText = NSAttributedString(string: "\(currentlySearchingFor): ", attributes: regularAttribute)
            let nothingHaveDuplicatesPaused = NSLocalizedString("nothingHaveDuplicatesPaused", comment: "Stats def=Nothing! You have duplicates, so Find is currently paused. Make sure that there are no duplicates in the Search Bar.")
            
            let boldMatchesText = NSAttributedString(string: nothingHaveDuplicatesPaused, attributes: boldAttribute)
            
            let newMatches = NSMutableAttributedString()
            newMatches.append(regularMatchesText)
            newMatches.append(boldMatchesText)
            statsNavController.viewController.currentSearchingForTheseWordsText = newMatches
        }
    
        self.present(statsNavController, animated: true)
        
    }
}
