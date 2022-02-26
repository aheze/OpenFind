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
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var highlightsView: UIView!
    
    let highlightsViewModel = HighlightsViewModel()
    
    let textToFind = "present"
    
    var currentTrackingImageIndex = 0
    let trackingImages: [UIImage] = [
//        UIImage(named: "TrackingImage1")!,
//        UIImage(named: "TrackingImage2")!,
//        UIImage(named: "TrackingImage3")!,
//        UIImage(named: "TrackingImage4")!,
//        UIImage(named: "TrackingImage5")!,
//        UIImage(named: "TrackingImage6")!,
//        UIImage(named: "TrackingImage7")!,
//        UIImage(named: "TrackingImage8")!,
//        UIImage(named: "TrackingImage9")!,
//        UIImage(named: "TrackingImage10")!,
//        UIImage(named: "TrackingImage11")!,
        UIImage(named: "Frame 1")!,
        UIImage(named: "Frame 2")!,
        UIImage(named: "Frame 3")!
    ]
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let rect = AVMakeRect(aspectRatio: trackingImages.first!.size, insideRect: imageView.frame)
        highlightsView.frame = rect
    }
    
    func updateTrackingImage(timer: Timer) {
        let image = trackingImages[currentTrackingImageIndex]
        imageView.image = image
        
        runFind(in: image.cgImage!)
        
        currentTrackingImageIndex += 1
        if currentTrackingImageIndex >= trackingImages.count {
            currentTrackingImageIndex = 0
        }
        if currentTrackingImageIndex >= 80 {
            timer.invalidate()
        }
    }
    
    func runFind(in image: CGImage) {
        Task {
            var options = FindOptions()
            options.level = .accurate
            guard let sentences = await Find.find(in: .cgImage(image), options: options, action: .camera, wait: false) else { return }
            
            var highlights = Set<Highlight>()
            for sentence in sentences {
//                for letter in sentence.letters {
//                    let highlight = Highlight(
//                        string: letter.string,
//                        frame: letter.frame,
//                        colors: [UIColor(hex: 0xff2600)]
//                    )
//                    highlights.insert(highlight)
//                }
                let sentenceString = sentence.getString()
                let indices = sentenceString.lowercased().indicesOf(string: textToFind.lowercased())
                for index in indices {
//                    let word = sentence.getWord(word: textToFind, at: index)

                    let range = index ..< index + textToFind.count
                    let (frame, angle) = sentence.getFrameAndRotation(for: range)
                    let highlight = Highlight(
                        string: textToFind,
                        frame: frame,
                        angle: angle,
                        colors: [UIColor(hex: 0xff2600)]
                    )
//                    let highlight = Highlight(
//                        string: self.textToFind,
//                        frame: word.frame,
//                        colors: [UIColor(hex: 0xff2600)]
//                    )

                    highlights.insert(highlight)
                }
//
            }
            
            highlightsViewModel.update(with: highlights, replace: false)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Timer.scheduledTimer(withTimeInterval: 1.2, repeats: true) { timer in
            self.updateTrackingImage(timer: timer)
        }
        
        let highlightsViewController = HighlightsViewController(highlightsViewModel: highlightsViewModel)
        addChildViewController(highlightsViewController, in: highlightsView)
        highlightsView.backgroundColor = .clear
        highlightsView.addDebugBorders(.blue)
        imageView.addDebugBorders(.green)
        view.bringSubviewToFront(highlightsView)
    }
}
