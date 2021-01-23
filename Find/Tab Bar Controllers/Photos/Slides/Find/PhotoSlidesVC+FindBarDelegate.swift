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
        if matchToColorsR.keys.count >= 1 {
            
            
            findFromCache(resultPhoto: resultPhotos[currentIndex], index: currentIndex)
        } else { /// no text entered
            changePromptToStarting()
            currentViewController.removeAllHighlights()
//            tableView.reloadData()
//            currentFastFindProcess = nil
//            self.progressView.alpha = 0
        }
        
        
    }
    
    func startedEditing(start: Bool) {
        print("startedEditing findbar")
    }
    
    func pressedReturn() {
        print("pressedReturn findbar------------, \(numberCurrentlyFindingFromCache)")
        if numberCurrentlyFindingFromCache == 0 {
            print("ues")
            
            setPromptToFastFinding()
            
            
            fastFind(resultPhoto: resultPhotos[currentIndex], index: currentIndex)
            
//            fastFind()
        }
    }
    
    func triedToEdit() {
        print("triedToEdit findbar")
    }
    
    func triedToEditWhilePaused() {
        print("ReturnSortedTerms triedToEditWhilePaused")
    }
    
}

