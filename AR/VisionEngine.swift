//
//  VisionEngine.swift
//  AR
//
//  Created by Zheng on 11/24/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import Vision

struct Area {
    var rect: CGRect
    var translation = CGSize.zero
    var image: CGImage?
    
    static func createAreas() {
        var areas = [Area]()
        let length = CGFloat(1) / 3
        
        for xOrigin in stride(from: 0, to: 1, by: length) {
            for yOrigin in stride(from: 0, to: 1, by: length) {
                let area = Area(
                    rect: CGRect(
                        x: xOrigin,
                        y: yOrigin,
                        width: length,
                        height: length
                    )
                )
                areas.append(area)
            }
        }
        self.areas = areas
    }
    
    static var areas = [Area]()
}
class VisionEngine {
    var currentImage: CGImage?
    var areas = Area.areas
    
    init() {
        Area.createAreas()
    }
    
    func beginTracking(with image: CVPixelBuffer) {
        guard let cgImage = CGImage.create(pixelBuffer: image) else {
            assertionFailure()
            return
        }
        self.currentImage = cgImage
        
        var areasWithImages = [Area]()
        for area in Area.areas {
            var areaWithImage = area
            
            let croppingRect = CGRect(
                x: area.rect.origin.x * CGFloat(cgImage.width),
                y: area.rect.origin.y * CGFloat(cgImage.height),
                width: area.rect.width * CGFloat(cgImage.width),
                height: area.rect.width * CGFloat(cgImage.height)
            )
            if let croppedImage = cgImage.cropping(to: croppingRect) {
                areaWithImage.image = croppedImage
            }
            
            areasWithImages.append(areaWithImage)
        }

        self.areas = areasWithImages
    }
    func updateTracking(with updatedImage: CVPixelBuffer, completion: @escaping (([Area]) -> Void)) {
        guard let currentImage = currentImage else { return }
        let group = DispatchGroup()
        
        for index in areas.indices {
            let area = areas[index]
            group.enter()
            
            var targetImage: CGImage
            if let croppedImage = area.image {
                targetImage = croppedImage
            } else {
                targetImage = currentImage
            }
            
//            let uiImage = UIImage(cgImage: targetImage)
//            let fullImage = UIImage(pixelBuffer: updatedImage)
//            if index == 4 {
//
//            }
            
            
            let request = VNTranslationalImageRegistrationRequest(
                targetedCGImage: targetImage,
                orientation: .up,
                options: [:]
            ) { request, error in
                let translation = self.processRequestTranslation(area: area, request: request)
                self.areas[index].translation = translation
                group.leave()
            }
            
//            request.regionOfInterest = CGRect(
//                x: area.rect.origin.x,
//                y: 1 - (area.rect.origin.y + area.rect.height),
//                width: area.rect.width,
//                height: area.rect.height
            //            )
            
            if let updatedCGImage = CGImage.create(pixelBuffer: updatedImage) {
                let croppingRect = CGRect(
                    x: area.rect.origin.x * CGFloat(updatedCGImage.width),
                    y: area.rect.origin.y * CGFloat(updatedCGImage.height),
                    width: area.rect.width * CGFloat(updatedCGImage.width),
                    height: area.rect.width * CGFloat(updatedCGImage.height)
                )
                if let croppedUpdatedImage = updatedCGImage.cropping(to: croppingRect) {
                    
                    let handler = VNImageRequestHandler(cgImage: croppedUpdatedImage)
                    do {
                        try handler.perform([request])
                    } catch {
                        print("Error performing request: \(error)")
                    }
                }
            }
        }
        group.notify(queue: .main) {
            print("All done!.. \(self.areas.map { $0.translation })")
            completion(self.areas)
        }
    }
    func processRequestTranslation(area: Area, request: VNRequest) -> CGSize {
        
        guard
            let observations = request.results,
            let observation = observations.compactMap({ $0 as? VNImageTranslationAlignmentObservation }).first
        else {
            return .zero
        }
        
        let translation = CGSize(
            width: observation.alignmentTransform.tx,
            height: observation.alignmentTransform.ty
        )
        
        return translation
    }
}
