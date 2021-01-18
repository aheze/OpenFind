//
//  PhotoFindVC+Prompt.swift
//  Find
//
//  Created by Zheng on 1/17/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import SwiftRichString

enum PromptType {
    case starting
    case finishedSearchingCache
    case finished
}
extension PhotoFindViewController {
    func changePromptToStarting(startingFilter: PhotoFilter, howManyPhotos: Int, isAllPhotos: Bool) {
        print("starting, all? \(isAllPhotos)")
         
        let findingFrom = "Finding from "
        let photos = "photos"
        
        let boldStyle = Style {
            $0.font = UIFont.systemFont(ofSize: 19, weight: .medium)
        }
        let grayStyle = Style {
            $0.color = UIColor.secondaryLabel
        }
        
        var number = isAllPhotos ? "all " : "\(howManyPhotos) " /// number of all
        let filter: String
        let color: UIColor
        switch startingFilter {
        
        case .local:
            filter = "local "
            color = UIColor(named: "100Blue")!
        case .starred:
            filter = "starred "
            color = UIColor(named: "Gold")!
        case .cached:
            filter = "cached "
            color = UIColor(named: "100Blue")!
        case .all:
            filter = "all "
            color = UIColor(named: "TabIconPhotosMain")!
            if isAllPhotos {
                number = ""
            } else {
                number = "\(howManyPhotos) of "
            }
        }
        
        let colorStyle = Style {
            $0.color = color
        }
        
        let attributedText = findingFrom.set(styles: [boldStyle, grayStyle]) + number.set(style: boldStyle) + filter.set(styles: [boldStyle, colorStyle]) + photos.set(styles: [boldStyle, grayStyle])
        promptLabel.attributedText = attributedText
    }
    func setPromptToHowManyCacheResults(howMany: Int) {
        let textStyle = Style {
            $0.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            $0.color = UIColor.secondaryLabel
        }
        
        var results = "results"
        if howMany == 1 {
            results = "result"
        }
        
        let resultsInCache = " \(results) in cached photos. Press ".set(style: textStyle)
        let toFindFromPhotos = " to find from uncached photos.".set(style: textStyle)
        
        let nextButtonAttachment = AttributedString(image: Image(named: "NextButton"), bounds: "0,-6,66,24")
        
        let attributedText = "\(howMany)".set(style: textStyle) + resultsInCache + nextButtonAttachment! + toFindFromPhotos
        promptLabel.attributedText = attributedText
    }
    func setPromptToHowManyFastFound(howMany: Int) { /// how many finished finding
        let textStyle = Style {
            $0.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            $0.color = UIColor.secondaryLabel
        }
        
//        let inProgress = "Finding from uncached photos (".set(style: textStyle)
//        let outOfWhat = "\(howMany)/\(findPhotos.count)".set(style: textStyle)
//        let ending = ")...".set(style: textStyle)
        
//        let attributedText = inProgress + outOfWhat + ending
        
        
        
        let attributedText = "Finding from uncached photos (\(howMany)/\(findPhotos.count))...".set(style: textStyle)
        promptLabel.attributedText = attributedText
    }
    /// Finished searching cache and uncached photos
    func setPromptToFinishedFastFinding(howMany: Int) {
        let textStyle = Style {
            $0.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            $0.color = UIColor.secondaryLabel
        }
        
        var results = "results"
        if howMany == 1 {
            results = "result"
        }
//        let inPhotos = "in \()"
        
        let attributedText = "\(howMany) \(results) in \(resultPhotos.count) photos".set(style: textStyle)
        promptLabel.attributedText = attributedText
    }
}

