//
//  FocusVisionHandler.swift
//  Find
//
//  Created by Andrew on 10/26/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import Foundation
import Vision

extension ViewController {
    
    func handleFocusDetectedText(request: VNRequest?, error: Error?) {
            if let error = error {
                print("ERROR: \(error)")
                return
            }
            guard let results = request?.results, results.count > 0 else {
                return
            }
            var components = [Component]()
            for result in results {
                //if stopTagFindingInNode == false {
                if let observation = result as? VNRecognizedTextObservation {
                   for text in observation.topCandidates(1) {
                      print(text.string)
                    let component = Component()
                    component.x = observation.boundingBox.origin.x
                    component.y = observation.boundingBox.origin.y
                    component.height = observation.boundingBox.height
                    component.width = observation.boundingBox.width
                    component.text = text.string
                    if component.text.contains(finalTextToFind) {
                        if numberOfFocusTimes % 2 == 0 {
                            getTextFocused(stringToFind: finalTextToFind, component: component, alternate: false)
                            print("first")
                        } else {
                            getTextFocused(stringToFind: finalTextToFind, component: component, alternate: true)
                        }
                    }
                }
                }
                
//                } else {
//                    print("stopping looooop")
//                    break
//                }
            }
            
          
        }
    
    
//    
//    
//    
//    let size = perspectiveImage.extent
//            for text in textObservations.topCandidates(1) {
//                //                 print("observe count \(textObservations.count)")
//                if stopFinding == false {
//    //                let centerPoint = textObservation.boundingBox.center
//                    //                print("CENTER: \(centerPoint)")
//                    let rect = textObservations.boundingBox
//                                            
//                                        
//                                        var xMin = CGFloat.greatestFiniteMagnitude
//                                        var xMax: CGFloat = 0
//                                        var yMin = CGFloat.greatestFiniteMagnitude
//                                        var yMax: CGFloat = 0
//                    //                    for rect in rects {
//                    //
//                    //
//                                            xMin = min(xMin, rect.minX)
//                                            xMax = max(xMax, rect.maxX)
//                                            yMin = min(yMin, rect.maxY)
//                                            yMax = max(yMax, rect.minY)
//                    var realX = xMin * size.width - 5
//                    var realY = yMin * size.height - 1
//                    var realWidth = (xMax - xMin) * size.width + 10
//                    var realHeight = (yMax - yMin) * size.height + 2
//                    print("realX:\(realX)---y:\(realY)")
//                
//                    let imageRect = CGRect(x: realX, y: realY, width: realWidth, height: realHeight)
//                    let context = CIContext(options: nil)
//                    guard let cgImage = context.createCGImage(perspectiveImage, from: imageRect) else {
//                        print("cgimge error")
//                        continue
//                    }
//                    
//                    let uiImage = UIImage(cgImage: cgImage)
//                    if prefilterYes == true {
//                    let stillImageFilter = GPUImageAdaptiveThresholdFilter()
//                    stillImageFilter.blurRadiusInPixels = 6
//                    }
//    //                if let filteredImage = stillImageFilter.image(byFilteringImage: uiImage) {
//    //                    focusTesseract?.image = filteredImage
//    //                    focusTesseract?.recognize()
//    //                }
//    //                } else {
//    //                    focusTesseract?.image = uiImage
//    //                    focusTesseract?.recognize()
//    //                }
//    //                guard var text = focusTesseract?.recognizedText else {
//    //                    print("textno")
//    //                    continue
//    //                }
//                        var text = "sdf"
//                    text = text.trimmingCharacters(in: CharacterSet.newlines)
//                    text = text.lowercased()
//                    if !text.isEmpty {
//                        
//                        var textArray = text.components(separatedBy: " ")
//                        var newText : String = ""
//                        let textChecker = UITextChecker()
//                        for singleText in textArray {
//                            let misspelledRange = textChecker.rangeOfMisspelledWord(in: singleText, range: NSRange(0..<singleText.utf16.count), startingAt: 0, wrap: false, language: "en_US")
//                            if misspelledRange.location != NSNotFound, let firstGuess = textChecker.guesses(forWordRange: misspelledRange, in: singleText, language: "en_US")?.first {
//                                
//                                newText = newText + " \(firstGuess)"
//                                
//                            } else {
//                                
//                                newText = newText + " \(singleText)"
//                                
//                            }
//                        }
//                        print(newText)
//                       
//                            let stringToFind = self.finalTextToFind.lowercased()
//                            var newestPoint = CGPoint(x: realX, y: realY)
//                        if let theAnchor = planes[blueNode] {
//                            let anchorImageSize = theAnchor.referenceImage.physicalSize
//    //                            self.getText(stringToFind: stringToFind, newText: newText, point: newestPoint, width: realWidth, height: realHeight, isFocusMode: true, focusImageSize: cgImageSize, realWorldSize: anchorImageSize)
//                        }
//                        
//                    }
//                } else {
//                    //MARK: break loop
//                    findingInNode = false
//                    let action = SCNAction.fadeOut(duration: 1)
//                    for h in self.focusHighlightArray {
//                        
//                        h.runAction(action, completionHandler: {() in
//                            h.removeFromParentNode()
//                            print("remove")
//                        })
//                        
//                    }
//                    
//                    for h in self.alternateFocusHighlightArray {
//                        h.runAction(action, completionHandler: {
//                            () in h.removeFromParentNode()
//                            print("remove123")
//                        })
//                    }
//    //
//                    print("break")
//                    break
//                }
//            }
    
    
    
    
}
