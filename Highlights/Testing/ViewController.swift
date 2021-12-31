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
    
    let image = UIImage(named: "Image")!
    
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
        
        let highlights: Set<Highlight> = [
            Highlight(
                string: "Text",
                frame: CGRect(x: 0.2, y: 0.2, width: 0.6, height: 0.6),
                colors: [UIColor(hex: 0xff2600)]
            )
        ]
        
        self.highlightsViewModel.highlights = highlights
    }
}



