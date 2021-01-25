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
            request.recognitionLanguages = ["en_GB"]
            
            request.progressHandler = { (_, progress, _) in
                print("progress is: \(progress)")
                let percent = progress * 100
                let roundedPercent = percent.rounded()
                self.messageView.updateMessage("Caching - \(roundedPercent)%")
            }
            let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: .up)
            do {
                try imageRequestHandler.perform([request])
            } catch let error {
                self.busyFastFinding = false
                print("Error: \(error)")
            }
        }
    }
}

