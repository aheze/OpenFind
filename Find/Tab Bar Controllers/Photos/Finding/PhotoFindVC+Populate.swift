//
//  PhotoFindVC+Populate.swift
//  Find
//
//  Created by Zheng on 1/15/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

class ResultPhoto: NSObject {
    var findPhoto = FindPhoto()
    var currentMatchToColors: [String: [CGColor]]? /// what is currently finding from
    var numberOfMatches = 0
    var descriptionText = ""
    var descriptionHeight = CGFloat(0)
    var descriptionMatchRanges = [ArrayOfMatchesInComp]()
    var components = [Component]()
}

extension PhotoFindViewController {
    func populatePhotos(findPhotos: [FindPhoto], currentFilter: PhotoFilter, findingFromAllPhotos: Bool, changedFromBefore: Bool) {

        let originalFindPhotoIdentifiers = self.findPhotos.map { $0.asset.localIdentifier }
        let newFindPhotoIdentifiers = findPhotos.map { $0.asset.localIdentifier }
        
        print(originalFindPhotoIdentifiers.containsSameElements(as: newFindPhotoIdentifiers))
        
        self.findPhotos = findPhotos
        self.currentFilter = currentFilter
        self.findingFromAllPhotos = findingFromAllPhotos
        
        if changedFromBefore || !originalFindPhotoIdentifiers.containsSameElements(as: newFindPhotoIdentifiers) {
            print("Changed!")
            changePromptToStarting(startingFilter: currentFilter, howManyPhotos: findPhotos.count, isAllPhotos: findingFromAllPhotos)
            currentFastFindProcess = nil
            resultPhotos.removeAll()
            tableView.reloadData()
            tableView.alpha = 1
            progressView.alpha = 0
            findBar.clearTextField()
        }
        
        
    }
}
