//
//  PhotoFindVC+FindBarDelegate.swift
//  Find
//
//  Created by Zheng on 1/16/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension PhotoFindViewController: FindBarDelegate {
    func pause(pause: Bool) {
    }
    
    func returnTerms(matchToColorsR: [String : [CGColor]]) {
        self.matchToColors = matchToColorsR
        if matchToColorsR.keys.count >= 1 {
            findFromCache()
        } else { /// no text entered
            changePromptToStarting(startingFilter: currentFilter, howManyPhotos: findPhotos.count, isAllPhotos: findingFromAllPhotos)
            resultPhotos.removeAll()
            tableView.reloadData()
            currentFastFindProcess = nil
            self.progressView.alpha = 0
            self.tableView.alpha = 1
        }
    }
    
    func startedEditing(start: Bool) {
    }
    
    func pressedReturn() {
        continuePressed(dismissKeyboard: false)
    }
    
    func triedToEdit() {
    }
    
    func triedToEditWhilePaused() {
    }
    
    func pressedContinue() {
        if numberCurrentlyFindingFromCache == 0 {
            setPromptToHowManyFastFound(howMany: 0)
            fastFind()
        }
    }
    
}
