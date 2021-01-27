//
//  EmptyDescription+Tips.swift
//  Find
//
//  Created by Zheng on 1/27/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension EmptyDescriptionView {
    func showTutorial() {
        makeTutorialButtonCurrentlyActive()
        startTutorial?(currentDisplayedFilter)
        showMeHowButton.setTitle("Stop tutorial", for: .normal)
    }
    func stopTutorial() {
        makeTutorialButtonEnabled()
        
    }
    
    func makeTutorialButtonEnabled() {
        showMeHowButton.setTitle("Show me how", for: .normal)
        switch currentDisplayedFilter {
        case .local:
            showMeHowButton.tintColor = UIColor(named: "100Blue")
        case .starred:
            showMeHowButton.tintColor = UIColor(named: "Gold")
        case .cached:
            showMeHowButton.tintColor = UIColor(named: "100Blue")
        case .all:
            break
        }
    }
    func makeTutorialButtonCurrentlyActive() { /// stop tutorial
        showMeHowButton.setTitle("Stop tutorial", for: .normal)
    }
    
    func showLocalTutorial() {
        
        
        
        
        
    }
}
