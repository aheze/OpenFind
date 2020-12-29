//
// ListBuilderVC+ErrorChecking.swift
// Find
//
// Created by Zheng on 12/29/20.
// Copyright © 2020 Andrew. All rights reserved.
//

import UIKit
import SwiftEntryKit

extension ListBuilderViewController {
    
    func findAndStoreErrors(contentsArray: [String]) { /// find errors and store in the error arrays
        generalVC.emptyStringErrors.removeAll()
        
        ///REFRESH
        generalVC.singleSpaceWarning.removeAll()
        generalVC.startSpaceWarning.removeAll()
        generalVC.endSpaceWarning.removeAll()
        
        let noDuplicateArray = contentsArray.uniques
        
        for (index, match) in contentsArray.enumerated() {
            if match == "" {
                generalVC.emptyStringErrors.append(index)
            }
        }///First, check for empty string.
        
        
        ///Now, check for duplicates
        generalVC.stringToIndexesError.removeAll() //
        if contentsArray.count !=  noDuplicateArray.count {
            
            let differentStrings = Array(Set(contentsArray.filter({ (i: String) in contentsArray.filter({ $0 == i }).count > 1}))) ///ContentsArray, but without duplicates
            
            var firstOccurrenceArray = [String]()
            for (index, singleContent) in contentsArray.enumerated() { ///Go through every match
                if differentStrings.contains(singleContent) {
                    if !firstOccurrenceArray.contains(singleContent) {
                        firstOccurrenceArray.append(singleContent)
                    } else { //A occurrence has already occurred.
                        generalVC.stringToIndexesError[singleContent, default: [Int]()].append(index)
                    }
                }
            }
        
        }
        ///check for empty spaces
        for (index, match) in contentsArray.enumerated() {
            if match == " " {
                generalVC.singleSpaceWarning.append(index)
            }
            if match.hasPrefix(" ") {
                generalVC.startSpaceWarning.append(index)
            }
            if match.hasSuffix(" ") {
                generalVC.endSpaceWarning.append(index)
            }
        }
    }
    
    func showDoneAlerts() -> Bool { ///For the end after pressing Save
        var showAnAlert = false
        
        if generalVC.emptyStringErrors.count >= 1 {
            let cantHaveEmptyMatch = NSLocalizedString("cantHaveEmptyMatch", comment: "GeneralViewController def=Can't have an empty match!")
            
            let youHaveXEmptyMatches = NSLocalizedString("youHave %d EmptyMatches",
                                                         comment:"GeneralViewController def=You have x empty matches!")
            
            var matchesPlural = String.localizedStringWithFormat(youHaveXEmptyMatches, generalVC.emptyStringErrors.count)
            
            if generalVC.emptyStringErrors.count == 1 { matchesPlural = cantHaveEmptyMatch }
            showAnAlert = true
            SwiftEntryKitTemplates().displaySEK(message: matchesPlural, backgroundColor: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), textColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), location: .top, duration: CGFloat(0.8))
            
            generalVC.highlightRowsOnError(type: "EmptyMatch")
        } else if generalVC.stringToIndexesError.count >= 1 { ///No empty errors. Only duplicates.
            var titleMessage = ""
            
            let dupStrings = generalVC.stringToIndexesError.keys
            var duplicateStringArray = [String]()
            for dup in dupStrings {
                duplicateStringArray.append(dup)
            }
            
            switch dupStrings.count {
            case 0:
                titleMessage = ""
            case 1:
                
                if let differentPaths = generalVC.stringToIndexesError[duplicateStringArray[0]] {
                    let aDuplicateOriginal = NSLocalizedString("aDuplicateOriginal", comment: "GeneralViewController def=a duplicate.")
                    
                    
                    var aDuplicate = aDuplicateOriginal
                    if differentPaths.count == 1 {
                        aDuplicate = aDuplicateOriginal
                    } else if differentPaths.count == 2 {
                        let twoDuplicates = NSLocalizedString("twoDuplicates", comment: "GeneralViewController def=2 duplicates.")
                        
                        aDuplicate = twoDuplicates
                    } else {
                        let aCoupleDuplicates = NSLocalizedString("aCoupleDuplicates", comment: "GeneralViewController def=a couple duplicates.")
                        aDuplicate = aCoupleDuplicates
                    }
                    
                    let xHasXDuplicates = NSLocalizedString("%@ has %@", comment:"GeneralViewController def=\"\(duplicateStringArray[0])\" has \(aDuplicate)")
                    
                    titleMessage = String.localizedStringWithFormat(xHasXDuplicates, duplicateStringArray[0], aDuplicate)
                }
            case 2:
                let xAndxHaveDuplicates = NSLocalizedString("%@ and %@ have",
                                                            comment:"GeneralViewController def=\"\(duplicateStringArray[0])\" and \"\(duplicateStringArray[1])\" have duplicates.")
                
                titleMessage = String.localizedStringWithFormat(xAndxHaveDuplicates, duplicateStringArray[0], duplicateStringArray[1])
                
            case 3..<4:
                var newString = ""
                for (index, message) in duplicateStringArray.enumerated() {
                    if index != duplicateStringArray.count - 1 {
                        newString.append("\"\(message)\", ")
                    } else {
                        
                        let and = NSLocalizedString("and", comment: "Multipurpose def=and")
                        newString.append(" \(and) \"\(message)\"")
                    }
                }
                
                let spaceHaveDuplicates = NSLocalizedString("spaceHaveDuplicates", comment:"GeneralViewController def= have duplicates.")
                
                titleMessage = newString + spaceHaveDuplicates
            default:
                
                let youHaveLotsDuplicates = NSLocalizedString("youHaveLotsDuplicates",
                                                              comment:"GeneralViewController def=You have a lot of duplicate matches.")
                titleMessage = youHaveLotsDuplicates
            }
            if titleMessage != "" {
                
                titleMessage = titleMessage.typographized(language: "en")
                var attributes = EKAttributes.topFloat
                attributes.displayDuration = .infinity
                attributes.entryInteraction = .absorbTouches
                attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .easeOut)
                attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
                attributes.screenBackground = .color(color: EKColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3802521008)))
                attributes.screenInteraction = .absorbTouches
                
                showAnAlert = true
                
                let wouldYouLikeDeleteDup = NSLocalizedString("wouldYouLikeDeleteDup",
                                                              comment:"GeneralViewController def=Would you like us to delete the duplicates?")
                
                let leftButtonDeleteSave = NSLocalizedString("leftButtonDeleteSave",
                                                             comment:"GeneralViewController def=Yes, Delete and save")
                
                let rightButtonFixItMyself = NSLocalizedString("rightButtonFixItMyself",
                                                               comment:"GeneralViewController def=I'll fix it myself")
                
                
                showButtonBarMessage(attributes: attributes, titleMessage: titleMessage, desc: wouldYouLikeDeleteDup, leftButton: leftButtonDeleteSave, yesButton: rightButtonFixItMyself)
            }
        }
        return showAnAlert
    }
    
    func showButtonBarMessage(attributes: EKAttributes, titleMessage: String, desc: String, leftButton: String, yesButton: String, image: String = "WhiteWarningShield", specialAction: String = "None") {
        let displayMode = EKAttributes.DisplayMode.inferred
        
        let title = EKProperty.LabelContent(text: titleMessage, style: .init(font: UIFont.systemFont(ofSize: 20, weight: .bold), color: .white, displayMode: displayMode))
        let description = EKProperty.LabelContent(text: desc, style: .init(font: UIFont.systemFont(ofSize: 14, weight: .regular), color: .white,displayMode: displayMode))
        let image = EKProperty.ImageContent( imageName: image, displayMode: displayMode, size: CGSize(width: 35, height: 35), contentMode: .scaleAspectFit)
        let simpleMessage = EKSimpleMessage(image: image, title: title, description: description)
        let buttonFont = UIFont.systemFont(ofSize: 20, weight: .bold)
        let okButtonLabelStyle = EKProperty.LabelStyle( font: UIFont.systemFont(ofSize: 20, weight: .bold), color: .white, displayMode: displayMode)
        let okButtonLabel = EKProperty.LabelContent( text: yesButton, style: okButtonLabelStyle)
        let closeButtonLabelStyle = EKProperty.LabelStyle(font: buttonFont, color: EKColor(#colorLiteral(red: 1, green: 0.9675828359, blue: 0.9005832124, alpha: 1)), displayMode: displayMode)
        let closeButtonLabel = EKProperty.LabelContent(text: leftButton, style: closeButtonLabelStyle)
        
        if specialAction == "None" {
            let okButton = EKProperty.ButtonContent(
                label: okButtonLabel,
                backgroundColor: .clear,
                highlightedBackgroundColor: Color.Gray.a800.with(alpha: 0.05)
            ) { [weak self] in
                self?.generalVC.highlightRowsOnError(type: "Duplicate")
                SwiftEntryKit.dismiss()
            }
            let closeButton = EKProperty.ButtonContent(
                label: closeButtonLabel,
                backgroundColor: .clear,
                highlightedBackgroundColor: Color.Gray.a800.with(alpha: 0.05),
                displayMode: displayMode
            ) { [weak self] in
                self?.generalVC.fixDuplicates {
                    SwiftEntryKit.dismiss()
                    self?.returnCompletedList()
                }
            }
            let buttonsBarContent = EKProperty.ButtonBarContent( with: closeButton, okButton, separatorColor: Color.Gray.light, buttonHeight: 60, displayMode: displayMode, expandAnimatedly: true )
            let alertMessage = EKAlertMessage( simpleMessage: simpleMessage, imagePosition: .left, buttonBarContent: buttonsBarContent
            )
            let contentView = EKAlertMessageView(with: alertMessage)
            contentView.backgroundColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
            contentView.layer.cornerRadius = 10
            SwiftEntryKit.display(entry: contentView, using: attributes)
        }
    }
}
