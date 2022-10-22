//
//  PhotoSlidesVC+FindBar.swift
//  Find
//
//  Created by Zheng on 1/21/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SnapKit
import UIKit

extension PhotoSlidesViewController {
    func setupFindBar() {
        let slideFindBar = SlideFindBar()
        view.addSubview(slideFindBar)
        
        slideFindBar.snp.makeConstraints { make in
            self.slideFindBarTopC = make.top.equalTo(view.safeArea.top).offset(-45).constraint
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(80)
        }
        view.layoutIfNeeded()
        
        slideFindBar.findBar.findBarDelegate = self
        slideFindBar.promptTextView.delegate = self
        self.slideFindBar = slideFindBar
        
        slideFindBar.promptBackgroundView.shouldGroupAccessibilityChildren = true
        slideFindBar.promptBackgroundView.accessibilityValue = "Finding from photos"
        
        slideFindBar.promptBackgroundView.activated = { [weak self] in
            guard let self = self else { return false }
            
            if self.continueButtonVisible {
                self.continuePressed()
                return true
            }
            return false
        }
    }
    
    @objc func findPressed(sender: UIBarButtonItem) {
        if slideFindBarTopC == nil {
            setupFindBar()
        }
        
        findPressed.toggle()
        
        if findPressed {
            findButton.title = NSLocalizedString("done", comment: "")
            findButton.accessibilityHint = "Stop finding from this photo. Removes the search bar."
            
            slideFindBarTopC?.update(offset: 0)
            
            if slideFindBar?.hasPrompt == true {
                animatePromptReveal(reveal: true)
            }
            
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
                
                self.slideFindBar?.alpha = 1
            }
            
            view.accessibilityElements = [slideFindBar, containerView, voiceOverSlidesControl]
            currentViewController.findingActive = true
            
            if !currentViewController.showingTranscripts {
                for highlight in currentViewController.resultPhoto.components {
                    highlight.baseView?.isHidden = false
                }
            }
            currentViewController.updateAccessibilityHints()
        } else {
            let Sentence = NSLocalizedString("universal-find", comment: "")
            findButton.title = Sentence
            findButton.accessibilityHint = "Find from this photo. Displays a search bar."
            
            slideFindBarTopC?.update(offset: -45)
            animatePromptReveal(reveal: false)
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
                self.slideFindBar?.alpha = 0
            }
            
            slideFindBar?.findBar.searchField.resignFirstResponder()
            view.accessibilityElements = nil
            currentViewController.findingActive = false
            
            for highlight in currentViewController.resultPhoto.components {
                highlight.baseView?.isHidden = true
            }
            currentViewController.updateAccessibilityHints()
        }
    }
}
