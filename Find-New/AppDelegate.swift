//
//  AppDelegate.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/2/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import RealmSwift
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var orientationLock = UIInterfaceOrientationMask.all

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }

    /// from https://stackoverflow.com/a/49729624/14351818
    enum AppUtility {
        static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                delegate.orientationLock = orientation
            }
        }

        static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation: UIInterfaceOrientation) {
            self.lockOrientation(orientation)
            UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        }

        static func setOrientation(_ rotateOrientation: UIInterfaceOrientation) {
            UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 17,

            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in

                /// Find v1.2
                if oldSchemaVersion == 16 {
                    var photoMetadatas = [PhotoMetadata]()
                    migration.enumerateObjects(ofType: "HistoryModel") { oldObject, _ in

                        guard let oldObject = oldObject else { return }

                        var photoMetadata = PhotoMetadata()

                        if let assetIdentifier = oldObject["assetIdentifier"] as? String {
                            photoMetadata.assetIdentifier = assetIdentifier
                        }

                        if let isHearted = oldObject["isHearted"] as? Bool, isHearted {
                            photoMetadata.isStarred = isHearted
                        }
                        photoMetadatas.append(photoMetadata)
                    }

                    var lists = [List]()
                    migration.enumerateObjects(ofType: "FindList") { oldObject, _ in
                        guard let oldObject = oldObject else { return }

                        var list = List()
                        if let name = oldObject["name"] as? String {
                            list.title = name
                        }

                        if let descriptionOfList = oldObject["descriptionOfList"] as? String {
                            list.description = descriptionOfList
                        }

                        if let iconImageName = oldObject["iconImageName"] as? String {
                            list.icon = iconImageName
                        }

                        if let iconColorName = oldObject["iconColorName"] as? String {
                            let color = UIColor(hexString: iconColorName)
                            if let hex = color.getHex() {
                                list.color = hex
                            }
                        }
                        if let contents = oldObject["contents"] as? RealmSwift.List<String> {
                            list.words = contents.map { $0 }
                        }
                        lists.append(list)
                    }

                    if let viewController = UIApplication.rootViewController as? ViewController {
                        viewController.loadMigratedData(migratedPhotoMetadatas: photoMetadatas, migratedLists: lists)
                    } else { /// if no view controller, cache data.
                        RealmContainer.migratedPhotoMetadatas = photoMetadatas
                        RealmContainer.migratedLists = lists
                    }

                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
            }
        )

        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config

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
}
