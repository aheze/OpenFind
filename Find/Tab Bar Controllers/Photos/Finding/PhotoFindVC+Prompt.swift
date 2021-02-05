//
//  PhotoFindVC+Prompt.swift
//  Find
//
//  Created by Zheng on 1/17/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import SwiftRichString

extension PhotoFindViewController {
    func changePromptToStarting(startingFilter: PhotoFilter, howManyPhotos: Int, isAllPhotos: Bool) {
         
        let findingFrom = NSLocalizedString("findingFrom", comment: "")
        
        let unit = NSLocalizedString("unitZhang", comment: "")
        
        let all = NSLocalizedString("allSpace", comment: "")
        let space = NSLocalizedString("blankSpace", comment: "")
        
        let photos = NSLocalizedString("findingFrom-photos", comment: "")
        
        let boldStyle = Style {
            $0.font = UIFont.systemFont(ofSize: 19, weight: .medium)
        }
        let grayStyle = Style {
            $0.color = UIColor.secondaryLabel
        }
        
        
        
        var number = isAllPhotos ? all : "\(howManyPhotos)\(unit)\(space)" /// number of all
        
        var overriddenLastPart: String?
        
        let filter: String
        let color: UIColor
        switch startingFilter {
        
        case .local:
            filter = "\(NSLocalizedString("lowercaseLocal", comment: ""))\(space)"
            color = UIColor(named: "100Blue")!
        case .starred:
            filter = "\(NSLocalizedString("lowercaseStarred", comment: ""))\(space)"
            color = UIColor(named: "Gold")!
        case .cached:
            filter = "\(NSLocalizedString("lowercaseCached", comment: ""))\(space)"
            color = UIColor(named: "100Blue")!
        case .all:
            filter = all
            color = UIColor(named: "TabIconPhotosMain")!
            if isAllPhotos {
                number = ""
            } else {
                let withinAllPhotos = NSLocalizedString("withinAllPhotos-Chinese", comment: "")
                if withinAllPhotos != "" { /// English is blank string
                    overriddenLastPart = "\(withinAllPhotos)\(howManyPhotos)\(unit)查找"
                } else {
                    number = "\(howManyPhotos) of "
                }
            }
        }
        
        let colorStyle = Style {
            $0.color = color
        }
        
        var attributedText = AttributedString()
        if let overriddenLastPart = overriddenLastPart {
            attributedText = findingFrom.set(styles: [boldStyle, grayStyle]) + filter.set(styles: [boldStyle, colorStyle]) + overriddenLastPart.set(styles: [boldStyle, grayStyle])
        } else {
            attributedText = findingFrom.set(styles: [boldStyle, grayStyle]) + number.set(style: boldStyle) + filter.set(styles: [boldStyle, colorStyle]) + photos.set(styles: [boldStyle, grayStyle])
        }
        
        
        promptLabel.attributedText = attributedText
    }
    func setPromptToHowManyCacheResults(howMany: Int) {
        let textStyle = Style {
            $0.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            $0.color = UIColor.secondaryLabel
        }
        
        let resultsText = NSLocalizedString("resultsText", comment: "")
        let resultText = NSLocalizedString("resultText", comment: "")
        let inCachedPhotos = NSLocalizedString("inCachedPhotos", comment: "")
        
        let toFindFromUncachedPhotos = NSLocalizedString("toFindFromUncachedPhotos", comment: "")
        let toFindWithOCR = NSLocalizedString("toFindWithOCR", comment: "")
        
        var results = resultsText
        if howMany == 1 {
            results = resultText
        }
        
        let resultsInCache = " \(results)\(inCachedPhotos) ".set(style: textStyle)
        var toFindFromPhotos = " \(toFindFromUncachedPhotos)".set(style: textStyle)
        
        if currentFilter == .cached {
            toFindFromPhotos = toFindWithOCR.set(style: textStyle)
        }
        
        let nextButtonAttachment = AttributedString(image: Image(named: "ContinueButton"), bounds: "0,-6,76,24")
        
        let attributedText = "\(howMany)".set(style: textStyle) + resultsInCache + nextButtonAttachment! + toFindFromPhotos
        promptLabel.attributedText = attributedText
    }
    func setPromptToHowManyFastFound(howMany: Int) { /// how many finished finding
        let textStyle = Style {
            $0.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            $0.color = UIColor.secondaryLabel
        }
        
        let findingFromUncachedPhotos = NSLocalizedString("findingFromUncachedPhotos", comment: "")
        let findingFromPhotos = NSLocalizedString("findingFromPhotos", comment: "")
        
        var attributedText = "\(findingFromUncachedPhotos) (\(howMany)/\(findPhotos.count))...".set(style: textStyle)
        
        if currentFilter == .cached {
            attributedText = "\(findingFromPhotos) (\(howMany)/\(findPhotos.count))...".set(style: textStyle)
        }
        
        promptLabel.attributedText = attributedText
    }
    /// Finished searching cache and uncached photos
    func setPromptToFinishedFastFinding(howMany: Int) {
        let textStyle = Style {
            $0.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            $0.color = UIColor.secondaryLabel
        }
        
        let resultsText = NSLocalizedString("resultsText", comment: "")
        let resultText = NSLocalizedString("resultText", comment: "")
        let spaceOrUnit = NSLocalizedString("spaceOrUnit", comment: "")
        
        var results = resultsText
        if howMany == 1 {
            results = resultText
        }
        
        let _in_ = NSLocalizedString("_in_", comment: "")
        let spaceOrZhangUnit = NSLocalizedString("spaceOrZhangUnit", comment: "")
        let lowercasePhotos = NSLocalizedString("lowercasePhotos", comment: "")
        
        let attributedText = "\(howMany)\(spaceOrUnit)\(results)\(_in_)\(resultPhotos.count)\(spaceOrZhangUnit)\(lowercasePhotos)".set(style: textStyle)
        promptLabel.attributedText = attributedText
    }
}

