//
//  VisionHandler.swift
//  Find
//
//  Created by Andrew on 10/13/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import Foundation
import Vision

extension ViewController {
    func handleDetectedText(request: VNRequest?, error: Error?) {
        if let error = error {
            print("ERROR: \(error)")
            return
        }
        guard let results = request?.results, results.count > 0 else {
            return
        }
        var components = [Component]()
        
        for result in results {
            if stopProcessingImage == false {
            if let observation = result as? VNRecognizedTextObservation {
               for text in observation.topCandidates(1) {
//                    print(text.string)
                let component = Component()
                component.x = observation.boundingBox.origin.x
                component.y = observation.boundingBox.origin.y
                component.height = observation.boundingBox.height
                component.width = observation.boundingBox.width
                component.text = text.string
                if component.text.contains(finalTextToFind) {
                    if processImageNumberOfPasses % 2 == 0 {
                        getTextClassic(stringToFind: finalTextToFind, component: component, alternate: false)
                        print("first")
                    } else {
                        getTextClassic(stringToFind: finalTextToFind, component: component, alternate: true)
                    }
                }
            }
            }
            
            } else {
                print("stopping loop")
                break
            }
        }
        
      
    }
}
