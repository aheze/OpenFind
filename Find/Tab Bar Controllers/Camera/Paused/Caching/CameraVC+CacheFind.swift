//
//  CameraVC+CacheFind.swift
//  Find
//
//  Created by Zheng on 1/25/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import Vision

extension CameraViewController {
    func cacheFind(in cgImage: CGImage) {
        startedCaching = true
        
        let thisProcessIdentifier = UUID()
        currentCachingProcess = thisProcessIdentifier
        
        DispatchQueue.global(qos: .userInitiated).async {
            let request = VNRecognizeTextRequest { request, error in
                self.handleCachedText(request: request, error: error, thisProcessIdentifier: thisProcessIdentifier)
            }
            
            var customFindArray = [String]()
            for list in self.selectedLists {
                for cont in list.contents {
                    customFindArray.append(cont)
                    customFindArray.append(cont.lowercased())
                    customFindArray.append(cont.uppercased())
                    customFindArray.append(cont.capitalizingFirstLetter())
                }
            }
            
            request.customWords = [self.finalTextToFind, self.finalTextToFind.lowercased(), self.finalTextToFind.uppercased(), self.finalTextToFind.capitalizingFirstLetter()] + customFindArray
            
            request.recognitionLevel = .accurate
            request.recognitionLanguages = Defaults.recognitionLanguages
            
            request.progressHandler = { _, progress, _ in
                if thisProcessIdentifier == self.currentCachingProcess {
                    self.currentProgress = CGFloat(progress)
                    let percent = progress * 100
                    let roundedPercent = Int(percent.rounded())
                    self.messageView.updateMessage("\(roundedPercent)")
                    if self.cachePressed {
                        DispatchQueue.main.async {
                            self.cache.cacheIcon.animateCheck(percentage: CGFloat(progress))
                            
                            UIAccessibility.post(notification: .announcement, argument: "\(roundedPercent)%")
                        }
                    }
                }
            }
            let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: .up)
            do {
                try imageRequestHandler.perform([request])
            } catch {
                self.busyFastFinding = false
            }
        }
    }
}
