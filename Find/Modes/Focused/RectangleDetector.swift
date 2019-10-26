/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 An object that checks images for rectangles.
 */

import UIKit
import Vision
import CoreImage
import ARKit

/// - Tag: RectangleDetector
extension ViewController {
   
    func search(in pixelBuffer: CVPixelBuffer) {
        guard !isLookingForRect else { return }
        isLookingForRect = true
        
        // Remember the current image.
        currentCameraImage = pixelBuffer
        // Note that the pixel buffer's orientation doesn't change even when the device rotates.
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)
        
        // Create a Vision rectangle detection request for running on the GPU.
        let request = VNDetectRectanglesRequest { request, error in
            self.completedVisionRequest(request, error: error)
            print("completed, howMany: \(request.results!.count)")
        }
        
        request.maximumObservations = 20
        // Require rectangles to be reasonably large.
        request.minimumSize = 0.1
        // Require high confidence for detection results.
        request.minimumConfidence = 0.80
        // Ignore rectangles with a too uneven aspect ratio.
        request.minimumAspectRatio = 0.3
        // Ignore rectangles that are skewed too much.
        request.quadratureTolerance = 35
        request.usesCPUOnly = false
        DispatchQueue.global().async {
            do {
                try handler.perform([request])
            } catch {
                print("Error: Rectangle detection failed - vision request failed.")
                self.isLookingForRect = false
            }
        }
        isLookingForRect = false
    }
    
    /// Check for a rectangle result.
    /// If one is found, crop the camera image and correct its perspective.
    /// - Tag: CropCameraImage
    private func completedVisionRequest(_ request: VNRequest?, error: Error?) {
        if (request?.results?.count)! >= 1 {
        var photoArray = [CIImage]()
        for rect in (request?.results)! {
        guard let rectangle = rect as? VNRectangleObservation else {
            guard let error = error else { return }
            print("Error: Rectangle detection failed - Vision request returned an error. \(error.localizedDescription)")
            return
        }
        guard let filter = CIFilter(name: "CIPerspectiveCorrection") else {
            print("Error: Rectangle detection failed - Could not create perspective correction filter.")
            return
        }
        let width = CGFloat(CVPixelBufferGetWidth(currentCameraImage))
        let height = CGFloat(CVPixelBufferGetHeight(currentCameraImage))
        let topLeft = CGPoint(x: rectangle.topLeft.x * width, y: rectangle.topLeft.y * height)
        let topRight = CGPoint(x: rectangle.topRight.x * width, y: rectangle.topRight.y * height)
        let bottomLeft = CGPoint(x: rectangle.bottomLeft.x * width, y: rectangle.bottomLeft.y * height)
        let bottomRight = CGPoint(x: rectangle.bottomRight.x * width, y: rectangle.bottomRight.y * height)
        filter.setValue(CIVector(cgPoint: topLeft), forKey: "inputTopLeft")
        filter.setValue(CIVector(cgPoint: topRight), forKey: "inputTopRight")
        filter.setValue(CIVector(cgPoint: bottomLeft), forKey: "inputBottomLeft")
        filter.setValue(CIVector(cgPoint: bottomRight), forKey: "inputBottomRight")
        
        let ciImage = CIImage(cvPixelBuffer: currentCameraImage).oriented(.up)
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        guard let perspectiveImage: CIImage = filter.value(forKey: kCIOutputImageKey) as? CIImage else {
            print("Error: Rectangle detection failed - perspective correction filter has no output image.")
            return
        }
            photoArray.append(perspectiveImage)
    }
           
            if photoArray.count >= 1 {
                rectangleFound(rectangleContents: photoArray)
            }
    }
        isLookingForRect = false
        
    }
    func rectangleFound(rectangleContents: [CIImage]) {
          var referenceImageArray = [ARReferenceImage]()
          for rectangleImage in rectangleContents {
              numberOfFocusTimes += 1
              guard let referenceImagePixelBuffer = rectangleImage.toPixelBuffer(pixelFormat: kCVPixelFormatType_32BGRA) else {
                  print("Error: Could not convert input image into an ARReferenceImage.")
                  return
              }
              
              let image = ARReferenceImage(referenceImagePixelBuffer, orientation: .up, physicalWidth: 0.2)
              image.name = "\(numberOfFocusTimes)"
              referenceImageArray.append(image)
              if let cgImage = referenceImagePixelBuffer.toCGImage() {
                  let uiImage = UIImage(cgImage: cgImage)
                  //images["\(numberOfFocusTimes)"] = uiImage
              }
              
          }
          imagesToTrack = referenceImageArray
          runImageTrackingSession(with: Set(imagesToTrack))
          
      }
}
