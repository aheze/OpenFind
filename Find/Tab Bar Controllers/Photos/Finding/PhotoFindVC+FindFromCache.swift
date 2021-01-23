//
//  PhotoFindVC+Find.swift
//  Find
//
//  Created by Zheng on 1/16/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension PhotoFindViewController {
    func findFromCache() {
        print("set to nil")
        currentFastFindProcess = nil
        totalCacheResults = 0
        var totalMatchNumber = 0
        
        if numberCurrentlyFindingFromCache == 0 {
            UIView.animate(withDuration: 0.2, animations: {
                self.tableView.alpha = 0.5
            })
        }
        
        numberCurrentlyFindingFromCache += 1
        
        DispatchQueue.global(qos: .userInitiated).async {
            var resultPhotos = [ResultPhoto]()
            
            
            for findPhoto in self.findPhotos {
                guard let editableModel = findPhoto.editableModel else { continue }
                  
                var numberOfMatches = 0 /// how many individual matches
                
                let resultPhoto = ResultPhoto()
                resultPhoto.findPhoto = findPhoto
                
                var descriptionOfPhoto = ""
                var textToRanges = [String: [ArrayOfMatchesInComp]]() ///COMPONENT to ranges
                
                ///Cycle through each block of text. Each cont may be a line long.
                for content in editableModel.contents {
                    
                    var matchRanges = [ArrayOfMatchesInComp]()
                    var hasMatch = false /// if this content has a match
                    
                    let lowercaseContentText = content.text.lowercased()
                    let individualCharacterWidth = CGFloat(content.width) / CGFloat(lowercaseContentText.count)
                    
                    for match in self.matchToColors.keys {
                        if lowercaseContentText.contains(match) {
                            hasMatch = true
                            let finalW = individualCharacterWidth * CGFloat(match.count)
                            let indices = lowercaseContentText.indicesOf(string: match)
                            
                            for index in indices {
                                totalMatchNumber += 1
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
                                existingCount += 3
                                
                                descriptionOfPhoto.append("...\(thisCompString)...")
                            } else {
                                existingCount += 4
                                descriptionOfPhoto.append("\n...\(thisCompString)...")
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
                    
                    resultPhotos.append(resultPhoto)
                }
                
                resultPhoto.descriptionMatchRanges = finalRangesObjects
                resultPhoto.numberOfMatches = numberOfMatches
                resultPhoto.descriptionText = descriptionOfPhoto
                let totalWidth = self.deviceWidth
                let finalWidth = totalWidth - 146
                let height = descriptionOfPhoto.heightWithConstrainedWidth(width: finalWidth, font: UIFont.systemFont(ofSize: 14))
                let finalHeight = height + 70
                resultPhoto.descriptionHeight = finalHeight
                
            }
            
            self.resultPhotos = resultPhotos
            
            DispatchQueue.main.async {
                
                self.numberCurrentlyFindingFromCache -= 1
                
                if self.numberCurrentlyFindingFromCache == 0 {
                    self.setPromptToHowManyCacheResults(howMany: totalMatchNumber)
                    
                    UIView.animate(withDuration: 0.1, animations: {
                        self.tableView.alpha = 1
                        self.progressView.alpha = 0
                    })
                    
                    self.tableView.reloadData()
                }
                
                self.totalCacheResults = totalMatchNumber
            }
            
        }
    }
}
