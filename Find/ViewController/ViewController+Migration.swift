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
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: globalUrl, includingPropertiesForKeys: nil)
           
            if !fileURLs.isEmpty { /// there are files here
                photoObjects = realm.objects(HistoryModel.self)
                
                var photoArray = [HistoryModel]()
                photoObjects?.forEach({ (photo) in
                    photoArray.append(photo)
                })
                
                photos.navController.viewController.migrationNeeded = true
                photos.navController.viewController.photosToMigrate = photoArray
                photos.navController.viewController.folderURL = globalUrl
            }
            
        } catch {

        }
    }
    
    func checkForOldUserDefaults() {
        if UserDefaults.standard.integer(forKey: "hapticFeedbackLevel") == 0 { /// level has not been set yet
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
