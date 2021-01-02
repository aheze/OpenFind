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
                print("has file urls \(fileURLs)")
            
            if !fileURLs.isEmpty { /// there are files here
                photos.viewController.migrationNeeded = true
//                photos.viewController.showMigrationView()
            }
            
        } catch {
            print("Error while enumerating files \(error.localizedDescription)")
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
