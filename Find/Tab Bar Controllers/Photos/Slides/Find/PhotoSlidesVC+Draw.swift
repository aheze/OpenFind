//
//  PhotoSlidesVC+Draw.swift
//  Find
//
//  Created by Zheng on 1/22/21.
//  Copyright © 2021 Zheng. All rights reserved.
//

import UIKit

extension PhotoSlidesViewController {
    func drawHighlights(components: [Component], transcripts: [Component]) {
        currentViewController.highlights = components
        currentViewController.currentTranscriptComponents = transcripts
        currentViewController.matchToColors = matchToColors
        currentViewController.drawHighlights()
        currentViewController.drawAllTranscripts(show: currentViewController.showingTranscripts)
    }
}


