//
//  ViewController+Migration.swift
//  Find
//
//  Created by Zheng on 1/1/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension ViewController {
    
    func checkIfHistoryImagesExist() {
        print("checking...")
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: globalUrl, includingPropertiesForKeys: nil)
           
            
            if !fileURLs.isEmpty { /// there are files here
                photos.viewController.migrationNeeded = true
                photos.viewController.photosToMigrate = fileURLs
//                photos.viewController.showMigrationView()
                
                photoCategories = realm.objects(HistoryModel.self)
                print("cats: \(photoCategories)")
                print("count: \(photoCategories?.count)")
                print("has file urls \(fileURLs.count)")
            }
            
        } catch {
            print("Error while enumerating files \(error.localizedDescription)")
        }
    }
    
    func checkForOldUserDefaults() {
        if UserDefaults.standard.integer(forKey: "hapticFeedbackLevel") == 0 { /// level has not been set yet
            print("Is 0!!!!")
            
            if UserDefaults.standard.bool(forKey: "hapticFeedback") == true { /// used to be on
                UserDefaults.standard.set(2, forKey: "hapticFeedbackLevel")
            } else {
                UserDefaults.standard.set(1, forKey: "hapticFeedbackLevel")
            }
        }
        
    }
}

extension FileManager {
    func urls(for directory: FileManager.SearchPathDirectory, skipsHiddenFiles: Bool = true ) -> [URL]? {
        let documentsURL = urls(for: directory, in: .userDomainMask)[0]
        let fileURLs = try? contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: skipsHiddenFiles ? .skipsHiddenFiles : [] )
        return fileURLs
    }
}
