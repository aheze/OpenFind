//
//  AppDelegate.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/2/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

//    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
//        // 1
//        guard
//            userActivity.activityType == NSUserActivityTypeBrowsingWeb,
//            let url = userActivity.webpageURL,
//            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
//        else {
//            return false
//        }
//        
//        Debug.show("URL: \(url)", message: "Components: \(components)")
//        print("url: \(url) -> Components: \(components)")
//
////        // 2
////        if let computer = ItemHandler.sharedInstance.items
////            .filter({ $0.path == components.path }).first
////        {
////            presentDetailViewController(computer)
////            return true
////        }
////
////        // 3
////        if let webpageUrl = URL(string: "http://rw-universal-links-final.herokuapp.com") {
////            application.open(webpageUrl)
////            return false
////        }
//
//        return false
//    }
}
