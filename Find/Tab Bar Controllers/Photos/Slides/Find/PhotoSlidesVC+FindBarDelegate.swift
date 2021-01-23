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
        print("Pause findbar")
    }
    
    func returnTerms(matchToColorsR: [String : [CGColor]]) {
        print("returnTerms findbar")
        print("curre index is: \(currentIndex)")
        
        self.matchToColors = matchToColorsR
        
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
            currentViewController.removeAllHighlights()
        }
    }
    
    func startedEditing(start: Bool) {
        print("startedEditing findbar")
    }
    
    func pressedReturn() {
        print("pressedReturn findbar------------, \(numberCurrentlyFindingFromCache)")
        if numberCurrentlyFindingFromCache == 0 {
            setPromptToFastFinding()
            fastFind(resultPhoto: resultPhotos[currentIndex], index: currentIndex)
        }
    }
    
    func triedToEdit() {
        print("triedToEdit findbar")
    }
    
    func triedToEditWhilePaused() {
        print("ReturnSortedTerms triedToEditWhilePaused")
    }
    
}

