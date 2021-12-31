//
//  ViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/30/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//
    

import UIKit
import AVFoundation

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var highlightsView: UIView!
    
    let highlightsViewModel = HighlightsViewModel()
    
    let textToFind = "pop"
    let image = UIImage(named: "Image2")!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let rect = AVMakeRect(aspectRatio: image.size, insideRect: imageView.frame)
        highlightsView.frame = rect
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let highlightsViewController = HighlightsViewController(highlightsViewModel: highlightsViewModel)
        addChildViewController(highlightsViewController, in: highlightsView)
        highlightsView.backgroundColor = .clear
        imageView.image = image
        
        Find.run(in: .cgImage(image.cgImage!)) { [weak self] sentences in
            guard let self = self else { return }
            
            var highlights = [Highlight]()
            for sentence in sentences {
                let indices = sentence.string.lowercased().indicesOf(string: self.textToFind.lowercased())
                for index in indices {
                    let word = sentence.getWord(word: self.textToFind, at: index)
                    
                    let highlight = Highlight(
                        string: self.textToFind,
                        frame: word.frame,
                        colors: [UIColor(hex: 0xff2600)]
                    )
                    
                    highlights.append(highlight)
                }
            }
            
            self.highlightsViewModel.highlights = highlights
            
        }
    }
}

