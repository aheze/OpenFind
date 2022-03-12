//
//  ViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/30/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//
    
import AVFoundation
import UIKit

class ViewController: UIViewController {
    let interval: CGFloat? = nil
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var highlightsView: UIView!
    
    let highlightsViewModel = HighlightsViewModel()
    
    let textToFind = ["hello", "some"]
    
    var currentTrackingImageIndex = 0
    let trackingImages: [UIImage] = [
        UIImage(named: "Frame 4")!,
    ]
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let rect = AVMakeRect(aspectRatio: trackingImages.first!.size, insideRect: imageView.frame)
        highlightsView.frame = rect
    }
    
    func updateTrackingImage(timer: Timer? = nil) {
        let image = trackingImages[currentTrackingImageIndex]
        imageView.image = image
        
        runFind(in: image.cgImage!)
        
        currentTrackingImageIndex += 1
        if currentTrackingImageIndex >= trackingImages.count {
            currentTrackingImageIndex = 0
        }
        if currentTrackingImageIndex >= 80 {
            timer?.invalidate()
        }
    }
    
    func runFind(in image: CGImage) {
        Task {
            var options = FindOptions()
            options.level = .accurate
            options.customWords = textToFind
            guard let sentences = await Find.find(in: .cgImage(image), options: options, action: .camera, wait: false) else { return }
            
            var highlights = Set<Highlight>()
            for sentence in sentences {
                let rangeResults = sentence.ranges(of: textToFind)
                for rangeResult in rangeResults {
                    for range in rangeResult.ranges {
                        let highlight = Highlight(
                            string: rangeResult.string,
                            colors: [UIColor(hex: 0xff2600)],
                            position: sentence.position(for: range)
                        )
                        
                        highlights.insert(highlight)
                    }
                }
                
//                for rangeToFrame in sentence.rangesToFrames {
//                    let highlight = Highlight(
//                        string: sentence.string(for: rangeToFrame.key),
//                        frame: rangeToFrame.value,
//                        colors: [UIColor.systemBlue],
//                        alpha: 0.2
//                    )
//                    highlights.insert(highlight)
//                }
            }
            
            highlightsViewModel.update(with: highlights, replace: false)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let interval = interval {
            Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
                self.updateTrackingImage(timer: timer)
            }
        } else { /// just find
            updateTrackingImage()
        }
        
        let highlightsViewController = HighlightsViewController(highlightsViewModel: highlightsViewModel)
        addChildViewController(highlightsViewController, in: highlightsView)
        highlightsView.backgroundColor = .clear
        highlightsView.addDebugBorders(.blue)
        imageView.addDebugBorders(.green)
        view.bringSubviewToFront(highlightsView)
    }
}
