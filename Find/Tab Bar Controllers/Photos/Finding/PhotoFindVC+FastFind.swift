//
//  PhotoFindVC+FastFind.swift
//  Find
//
//  Created by Zheng on 1/17/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import Photos
import Vision

extension PhotoFindViewController {
    func fastFind() {
        let thisProcessIdentifier = UUID()
        currentFastFindProcess = thisProcessIdentifier
        
        var fastFindResultsNumber = 0
        
        DispatchQueue.main.async {
            
            self.progressView.setProgress(Float(0), animated: false)
            UIView.animate(withDuration: 0.5, animations: {
                self.progressView.alpha = 1
                self.tableView.alpha = 0.5
            })
        }
        
        let photosToFindFrom = self.findPhotos
        
        dispatchQueue.async {
            self.numberFastFound = 0
            
            for findPhoto in photosToFindFrom {
                var stop = false
                
                autoreleasepool {
                    if thisProcessIdentifier == self.currentFastFindProcess {
                        self.dispatchGroup.enter()
                        
                        let options = PHImageRequestOptions()
                        options.isSynchronous = true
                        
                        PHImageManager.default().requestImageDataAndOrientation(for: findPhoto.asset, options: options) { (data, _, _, _) in
                            if let imageData = data {
                                let request = VNRecognizeTextRequest { request, error in
                                    let howManyMatches = self.handleFastDetectedText(request: request, error: error, photo: findPhoto, thisProcessIdentifier: thisProcessIdentifier)
                                    fastFindResultsNumber += howManyMatches
                                }
                                request.recognitionLevel = .fast
                                request.recognitionLanguages = ["en_GB"]
                                request.recognitionLanguages = Defaults.recognitionLanguages
                                var customFindArray = [String]()
                                for findWord in self.matchToColors.keys {
                                    customFindArray.append(findWord)
                                    customFindArray.append(findWord.lowercased())
                                    customFindArray.append(findWord.uppercased())
                                    customFindArray.append(findWord.capitalizingFirstLetter())
                                }
                                
                                request.customWords = customFindArray
                                
                                
                                let imageRequestHandler = VNImageRequestHandler(data: imageData, orientation: .up, options: [:])
                                do {
                                    try imageRequestHandler.perform([request])
                                } catch let error {
                                    print("Error: \(error)")
                                }
                                
                                self.dispatchSemaphore.wait()
                            }
                        }
                    } else {
                        stop = true // call this if you need to stop
                    }
                }
                
                if stop { break }
            }
            
        }
        dispatchGroup.notify(queue: dispatchQueue) {
            if thisProcessIdentifier == self.currentFastFindProcess {
                DispatchQueue.main.async {
                    
                    self.setPromptToFinishedFastFinding(howMany: self.totalCacheResults + fastFindResultsNumber)
                    
                    self.tableView.reloadData()
                    
                    
                    UIView.animate(withDuration: 0.1, animations: {
                        self.tableView.alpha = 1
                        self.progressView.alpha = 0
                    })
                }
                self.currentFastFindProcess = nil
            }
        }
    }
    
    
    func handleFastDetectedText(request: VNRequest?, error: Error?, photo: FindPhoto, thisProcessIdentifier: UUID) -> Int {
        
        guard
            thisProcessIdentifier == currentFastFindProcess,
            let results = request?.results,
            results.count > 0 else {
            dispatchSemaphore.signal()
            dispatchGroup.leave()
            return 0
        }
        
        
        var fastFindResultsNumber = 0
        
        numberFastFound += 1
        DispatchQueue.main.async {
            let individualProgress = CGFloat(self.numberFastFound) / CGFloat(self.findPhotos.count)
            UIView.animate(withDuration: 0.6, animations: {
                self.progressView.setProgress(Float(individualProgress), animated: true)
            })
            self.setPromptToHowManyFastFound(howMany: self.numberFastFound)
        }
        
        var transcripts = [Component]()
        
        for result in results {
            if let observation = result as? VNRecognizedTextObservation {
                for text in observation.topCandidates(1) {
                    
                    let origX = observation.boundingBox.origin.x
                    let origY = 1 - observation.boundingBox.minY
                    let origWidth = observation.boundingBox.width
                    let origHeight = observation.boundingBox.height
                    
                    let transcript = Component()
                    transcript.text = text.string
                    transcript.x = origX
                    transcript.y = origY
                    transcript.width = origWidth
                    transcript.height = origHeight
                    transcripts.append(transcript)
                }
            }
        }
        
        let resultPhoto = ResultPhoto()
        resultPhoto.findPhoto = photo
        resultPhoto.transcripts = transcripts
        
        var descriptionOfPhoto = ""
        var textToRanges = [String: [ArrayOfMatchesInComp]]() ///COMPONENT to ranges
        var numberOfMatches = 0
        
        for content in transcripts {
            var matchRanges = [ArrayOfMatchesInComp]()
            var hasMatch = false
            
            let lowercaseContentText = content.text.lowercased()
            
            let individualCharacterWidth = CGFloat(content.width) / CGFloat(lowercaseContentText.count)
            for match in self.matchToColors.keys {
                if lowercaseContentText.contains(match) {
                    hasMatch = true
                    let finalW = individualCharacterWidth * CGFloat(match.count)
                    let indices = lowercaseContentText.indicesOf(string: match)
                    
                    for index in indices {
                        numberOfMatches += 1
                        let addedWidth = individualCharacterWidth * CGFloat(index)
                        let finalX = CGFloat(content.x) + addedWidth
                        
                        let newComponent = Component()
                        
                        newComponent.x = finalX
                        newComponent.y = CGFloat(content.y) - (CGFloat(content.height))
                        newComponent.width = finalW
                        newComponent.height = CGFloat(content.height)
                        newComponent.text = match
                        
                        resultPhoto.components.append(newComponent)
                        
                        let newRangeObject = ArrayOfMatchesInComp()
                        newRangeObject.descriptionRange = index...index + match.count
                        newRangeObject.text = match
                        matchRanges.append(newRangeObject)
                        
                    }
                }
            }
            if hasMatch == true {
                textToRanges[content.text] = matchRanges
            }
        }
        
        var finalRangesObjects = [ArrayOfMatchesInComp]()
        
        if numberOfMatches >= 1 {
            var existingCount = 0
            for (index, comp) in textToRanges.enumerated() {
                if index <= 2 {
                    let thisCompString = comp.key
                    
                    if descriptionOfPhoto == "" {
                        descriptionOfPhoto.append("\(thisCompString)...")
                    } else {
                        existingCount += 1
                        descriptionOfPhoto.append("\n\(thisCompString)...")
                    }
                    for compRange in comp.value {
                        let newStart = existingCount + (compRange.descriptionRange.first ?? 0)
                        let newEnd = existingCount + (compRange.descriptionRange.last ?? 1)
                        let newRange = newStart...newEnd
                        
                        let matchObject = ArrayOfMatchesInComp()
                        matchObject.descriptionRange = newRange
                        matchObject.text = compRange.text
                        
                        finalRangesObjects.append(matchObject)
                    }
                    let addedLength = 3 + thisCompString.count
                    existingCount += addedLength
                }
            }
            
            var foundSamePhoto = false
            for existingPhoto in self.resultPhotos {
                
                let localIdentifier = existingPhoto.findPhoto.asset.localIdentifier
                if photo.asset.localIdentifier == localIdentifier {
                    foundSamePhoto = true
                    
                    var componentsToAdd = [Component]()
                    var newMatchesNumber = 0
                    
                    for newFindMatch in resultPhoto.components {
                        var smallestDistance = CGFloat(999)
                        for findMatch in existingPhoto.components {
                            
                            let point1 = CGPoint(x: findMatch.x, y: findMatch.y)
                            let point2 = CGPoint(x: newFindMatch.x, y: newFindMatch.y)
                            let pointDistance = relativeDistance(point1, point2)
                            
                            if pointDistance < smallestDistance {
                                smallestDistance = pointDistance
                            }
                            
                        }
                        
                        if smallestDistance >= 0.008 { ///Bigger, so add it
                            componentsToAdd.append(newFindMatch)
                            newMatchesNumber += 1
                        }
                        
                    }
                    
                    existingPhoto.components += componentsToAdd
                    existingPhoto.numberOfMatches += newMatchesNumber
                    fastFindResultsNumber += newMatchesNumber
                    print("ADD MATCHES: \(newMatchesNumber)")
                    
                }
            }
            
            if foundSamePhoto == false {
                let totalWidth = self.deviceWidth
                let finalWidth = totalWidth - 146
                let height = descriptionOfPhoto.heightWithConstrainedWidth(width: finalWidth, font: UIFont.systemFont(ofSize: 14))
                let finalHeight = height + 70
                
                resultPhoto.descriptionMatchRanges = finalRangesObjects
                resultPhoto.numberOfMatches = numberOfMatches
                resultPhoto.descriptionText = descriptionOfPhoto
                resultPhoto.descriptionHeight = finalHeight
                
                resultPhotos.append(resultPhoto)
                
                fastFindResultsNumber = numberOfMatches
            }
        }
        
        dispatchSemaphore.signal()
        dispatchGroup.leave()
        
        return fastFindResultsNumber
    }
}

extension PhotoFindViewController {
    func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt(xDist * xDist + yDist * yDist))
    }
    func relativeDistance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(xDist * xDist + yDist * yDist)
    }
}
