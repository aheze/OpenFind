//
//  PhotoSlidesVC+FindBarDelegate.swift
//  Find
//
//  Created by Zheng on 1/22/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension PhotoSlidesViewController: FindBarDelegate {
    func pause(pause: Bool) {
    }
    
    func returnTerms(matchToColorsR: [String : [HighlightColor]]) {
        
        for highlight in currentViewController.resultPhoto.components {
            highlight.baseView?.removeFromSuperview()
        }
        matchToColors = matchToColorsR
        
        let resultPhoto = resultPhotos[currentIndex]
        resultPhoto.currentMatchToColors = nil
        resultPhoto.components.removeAll()
        if matchToColorsR.keys.count >= 1 {
            
            if let editableModel = resultPhoto.findPhoto.editableModel, editableModel.isDeepSearched {
                findFromCache(resultPhoto: resultPhoto, index: currentIndex)
            } else {
                setPromptToContinue()
            }
        } else { /// no text entered
            changePromptToStarting()
        }
    }
    
    func startedEditing(start: Bool) {
    }
    
    func pressedReturn() {
        pressedContinue()
    }
    
    func triedToEdit() {
        print("triedToEdit findbar")
    }
    
    func triedToEditWhilePaused() {
    }
    
    func pressedContinue() {
        if numberCurrentlyFindingFromCache == 0 {
            setPromptToFastFinding()
            fastFind(resultPhoto: resultPhotos[currentIndex], index: currentIndex)
        }
    }
}

