//
//  RateTheApp.swift
//  Find
//
//  Created by Zheng on 4/1/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit
import StoreKit

enum AppStoreReviewManager {
    static let minimumReviewWorthyActionCount = 15
    
    static func increaseReviewActionCount() {
        let defaults = UserDefaults.standard
        
        var actionCount = defaults.integer(forKey: "reviewWorthyActionCount")
        actionCount += 1
        
        defaults.set(actionCount, forKey: "reviewWorthyActionCount")
    }
    
    static func requestReviewIfPossible() {
        if !isForcingStatusBarHidden {
            let defaults = UserDefaults.standard
            let bundle = Bundle.main
            
            let actionCount = defaults.integer(forKey: "reviewWorthyActionCount")
            guard actionCount >= minimumReviewWorthyActionCount else {
                return
            }
            
            let bundleVersionKey = kCFBundleVersionKey as String
            let currentVersion = bundle.object(forInfoDictionaryKey: bundleVersionKey) as? String
            let lastVersion = defaults.string(forKey: "lastReviewRequestAppVersion")
            
            guard lastVersion == nil || lastVersion != currentVersion else {
                return
            }
            
            SKStoreReviewController.requestReview()
            
            defaults.set(0, forKey: "reviewWorthyActionCount")
            defaults.set(currentVersion, forKey: "lastReviewRequestAppVersion")
        }
    }
}
