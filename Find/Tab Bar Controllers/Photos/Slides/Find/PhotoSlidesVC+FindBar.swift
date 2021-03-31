//
//  PhotoSlidesVC+FindBar.swift
//  Find
//
//  Created by Zheng on 1/21/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import SnapKit

extension PhotoSlidesViewController {
    func setupFindBar() {
        let slideFindBar = SlideFindBar()
        view.addSubview(slideFindBar)
        
        slideFindBar.snp.makeConstraints { (make) in
            self.slideFindBarTopC = make.top.equalTo(view.safeArea.top).offset(-45).constraint
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(80)
        }
        view.layoutIfNeeded()
        
        slideFindBar.findBar.findBarDelegate = self
        slideFindBar.promptTextView.delegate = self
        self.slideFindBar = slideFindBar
    }
    
    
    @objc func findPressed(sender: UIBarButtonItem) {
        if slideFindBarTopC == nil {
            setupFindBar()
        }
        
        findPressed.toggle()
        
        if findPressed {
            findButton.title = NSLocalizedString("done", comment: "")
            
            slideFindBarTopC?.update(offset: 0)
            
            if slideFindBar?.hasPrompt == true {
                animatePromptReveal(reveal: true)
            }
            
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
                
                self.slideFindBar?.alpha = 1
            }
            
            view.accessibilityElements = [slideFindBar, containerView, voiceOverSlidesControl]
        } else {
            let findText = NSLocalizedString("universal-find", comment: "")
            findButton.title = findText
            
            slideFindBarTopC?.update(offset: -45)
            animatePromptReveal(reveal: false)
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
                self.slideFindBar?.alpha = 0
            }
            
            slideFindBar?.findBar.searchField.resignFirstResponder()
            view.accessibilityElements = nil
        }
    }
}

