//
//  CachingFinder.swift
//  Find
//
//  Created by Zheng on 2/9/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import Photos
import Vision
import RealmSwift

class CachingFinder {
    
    static var startedFindingFromNewPhoto: ((Int) -> Void)? /// got to new photo
    static var completedAnotherPhoto: ((Int) -> Void)? /// number cached
    
    static var finishedCancelling: (() -> Void)?
    static var finishedFind: ((UUID?) -> Void)?
    
    static var reportProgress: ((CGFloat) -> Void)?
    static var currentCachingIdentifier: UUID?
    static var customWords = [String]()
    
    static let realm = try! Realm()
    static var getRealRealmModel: ((EditableHistoryModel) -> HistoryModel?)? /// get real realm managed object
    
    static let dispatchGroup = DispatchGroup()
    static let dispatchQueue = DispatchQueue(label: "taskQueue")
    static let dispatchSemaphore = DispatchSemaphore(value: 0)
    
    // MARK: Track which photos have been cached
    static var numberCached = 0
    static var photosToCache = [FindPhoto]()
    static var alreadyCachedPhotos = [FindPhoto]()
    static var unsavedContents: [EditableSingleHistoryContent]? /// for temp caching
    
    static var statusOk = true ///OK = Running, no cancel
    
    
    static func load(with photosToCache: [FindPhoto], customWords: [String] = []) {
        self.photosToCache = photosToCache
        self.customWords = customWords
    }
    
    static func startFinding() {
        
        dispatchQueue.async {
            self.numberCached = 0
            var number = 0
            for findPhoto in self.photosToCache {
                if self.statusOk == true {
                    number += 1
                    CachingFinder.startedFindingFromNewPhoto?(number)
                    
                    if let model = findPhoto.editableModel, model.isDeepSearched == true {
                        self.numberCached += 1
                        CachingFinder.completedAnotherPhoto?(self.numberCached)
                        continue
                    } else {
                        self.dispatchGroup.enter()
                        let options = PHImageRequestOptions()
                        options.isSynchronous = true
                        
                        PHImageManager.default().requestImageDataAndOrientation(for: findPhoto.asset, options: options) { (data, _, _, _) in
                            if let imageData = data {
                                
                                let savedID = currentCachingIdentifier /// save for the current cycle
                                
                                let request = VNRecognizeTextRequest { request, error in
                                    self.handleFastDetectedText(request: request, error: error, photo: findPhoto, currentID: savedID)
                                }
                                request.recognitionLevel = .accurate
                                request.recognitionLanguages = ["en_GB"]
                                
                                if !customWords.isEmpty {
                                    request.customWords = customWords
                                }
                                
                                
                                request.progressHandler = { (_, progress, _) in
                                    if let savedID = savedID, savedID == currentCachingIdentifier {
                                        self.reportProgress?(CGFloat(progress))
                                    }
                                }
                                
                                let imageRequestHandler = VNImageRequestHandler(data: imageData, orientation: .up, options: [:])
                                do {
                                    try imageRequestHandler.perform([request])
                                } catch let error {
                                    print("Error: \(error)")
                                }
                            }
                        }
                        
                        self.dispatchSemaphore.wait()
                    }
                    
                } else {
                    break
                }
            }
        }
        dispatchGroup.notify(queue: dispatchQueue) {
            print("Finished caching.")
            if reportProgress == nil {
                if self.statusOk == false {
                    DispatchQueue.main.async {
                        CachingFinder.finishedCancelling?()
                    }
                } else {
                    CachingFinder.finishedFind?(currentCachingIdentifier)
                }
            }
        }
        
    }
    static func handleFastDetectedText(request: VNRequest?, error: Error?, photo: FindPhoto, currentID: UUID?) {
        
        numberCached += 1
        CachingFinder.completedAnotherPhoto?(self.numberCached)
        
        DispatchQueue.main.async {
            
            var contents = [EditableSingleHistoryContent]()
            
            if let results = request?.results, results.count > 0 {
                for result in results {
                    if let observation = result as? VNRecognizedTextObservation {
                        for text in observation.topCandidates(1) {
                            let origX = observation.boundingBox.origin.x
                            let origY = 1 - observation.boundingBox.minY
                            let origWidth = observation.boundingBox.width
                            let origHeight = observation.boundingBox.height
                            
                            let singleContent = EditableSingleHistoryContent()
                            singleContent.text = text.string
                            singleContent.x = origX
                            singleContent.y = origY
                            singleContent.width = origWidth
                            singleContent.height = origHeight
                            contents.append(singleContent)
                        }
                    }
                }
            }
            
            if reportProgress == nil && currentID == nil {
                saveToDisk(photo: photo, contentsToSave: contents)
            } else {
                unsavedContents = contents
                finishedFind?(currentID)
            }
            
            alreadyCachedPhotos.append(photo)
            dispatchSemaphore.signal()
            dispatchGroup.leave()
        }
    }
    
    static func saveToDisk(photo: FindPhoto, contentsToSave: [EditableSingleHistoryContent]) {
        if let editableModel = photo.editableModel {
            if let realModel = self.getRealRealmModel?(editableModel) {
                if !realModel.isDeepSearched {
                    do {
                        try self.realm.write {
                            realModel.isDeepSearched = true
                            self.realm.delete(realModel.contents)
                            
                            for cont in contentsToSave {
                                let realmContent = SingleHistoryContent()
                                realmContent.text = cont.text
                                realmContent.height = Double(cont.height)
                                realmContent.width = Double(cont.width)
                                realmContent.x = Double(cont.x)
                                realmContent.y = Double(cont.y)
                                realModel.contents.append(realmContent)
                            }
                        }
                    } catch {
                        print("Error saving cache. \(error)")
                    }
                    editableModel.isDeepSearched = true
                    editableModel.contents = contentsToSave
                }
            }
        } else {
            let newModel = HistoryModel()
            newModel.assetIdentifier = photo.asset.localIdentifier
            newModel.isDeepSearched = true
            newModel.isTakenLocally = false
            
            do {
                try self.realm.write {
                    self.realm.add(newModel)
                    
                    for cont in contentsToSave {
                        let realmContent = SingleHistoryContent()
                        realmContent.text = cont.text
                        realmContent.height = Double(cont.height)
                        realmContent.width = Double(cont.width)
                        realmContent.x = Double(cont.x)
                        realmContent.y = Double(cont.y)
                        newModel.contents.append(realmContent)
                    }
                }
            } catch {
                print("Error saving model \(error)")
            }
            
            let editableModel = EditableHistoryModel()
            editableModel.assetIdentifier = photo.asset.localIdentifier
            editableModel.isDeepSearched = true
            editableModel.isTakenLocally = false
            editableModel.contents = contentsToSave /// set the contents
            
            photo.editableModel = editableModel
        }
    }
    
    static func resetState() {
        startedFindingFromNewPhoto = nil
        completedAnotherPhoto = nil
        finishedCancelling = nil
        finishedFind = nil
        getRealRealmModel = nil
        numberCached = 0
        photosToCache.removeAll()
        alreadyCachedPhotos.removeAll()
        statusOk = true
        
        reportProgress = nil
        currentCachingIdentifier = nil
        customWords.removeAll()
    }
}
