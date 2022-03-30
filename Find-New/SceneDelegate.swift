//
//  SceneDelegate.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/2/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    /// handle a deeplinked URL
    func handleIncomingURL(_ url: URL) {
        if let viewController = window?.rootViewController as? ViewController {
            viewController.handleIncomingURL(url)
        }
    }

    /// Universal Links
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        if
            userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let incomingURL = userActivity.webpageURL
        {
            handleIncomingURL(incomingURL)
        }
    }

    /// URL Schemes
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let urlContext = URLContexts.first {
            let incomingURL = urlContext.url
            handleIncomingURL(incomingURL)
        }
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        if
            
            /// Universal Links
            let userActivity = connectionOptions.userActivities.first,
            userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let incomingURL = userActivity.webpageURL
        {
            handleIncomingURL(incomingURL)
        } else if
            
            /// URL Schemes
            let urlContext = connectionOptions.urlContexts.first
        {
            let sendingAppID = urlContext.options.sourceApplication
            let incomingURL = urlContext.url
            handleIncomingURL(incomingURL)
        }

        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        ConstantVars.configure(window: window)
        if let window = window {
            Global.window = window
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}
