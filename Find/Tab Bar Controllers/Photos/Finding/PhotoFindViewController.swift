//
//  PhotoFindViewController.swift
//  Find
//
//  Created by Zheng on 1/15/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

class PhotoFindViewController: UIViewController {
    
    var selfPresented: (() -> Bool)?
    
    // MARK: Find bar
    @IBOutlet weak var findBar: FindBar!
    @IBOutlet var promptView: PromptView!
    @IBOutlet weak var promptTextView: UITextView!
    var continueButtonVisible = false /// if true, set accessibility activate to true
    var shouldAnnounceStatus = false
    
    // MARK: Finding
    var matchToColors = [String: [HighlightColor]]()
    var currentFilter = PhotoFilter.all
    var findingFromAllPhotos = false /// if finding from all photos in filter
    
    // MARK: Find from cache
    var numberCurrentlyFindingFromCache = 0 /// how many cache findings are currently going on
    var deviceWidth = UIScreen.main.bounds.width
    var totalCacheResults = 0
    
    // MARK: Fast find from OCR
    var currentFastFindProcess: UUID?
    var numberFastFound = 0 /// how many fast found so far, for the progress view
    let dispatchGroup = DispatchGroup()
    let dispatchQueue = DispatchQueue(label: "ocrFastFindQueue")
    let dispatchSemaphore = DispatchSemaphore(value: 0)
    
    // MARK: Present photo
    var selectedIndexPath: IndexPath?
    var currentlyPresentingSlides = false /// whether currently presenting the slides or not
    var changePresentationMode: ((Bool) -> Void)? /// notify the parent to change the tab bar
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var findPhotos = [FindPhoto]() /// photos to find from
    var resultPhotos = [ResultPhoto]() /// photos displayed in table view
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        promptTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        promptTextView.delegate = self
        
        setupAccessibility()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Dynamic sizing for the prompt view
        if let headerView = tableView.tableHeaderView {
            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var headerFrame = headerView.frame
            
            // If we don't have this check, viewDidLayoutSubviews() will get
            // repeatedly, causing the app to hang.
            if height != headerFrame.size.height {
                headerFrame.size.height = height
                headerView.frame = headerFrame
                tableView.tableHeaderView = headerView
            }
        }
        
        
        if let textField = findBar.searchField {
            let frame = UIAccessibility.convertToScreenCoordinates(
                textField.bounds.inset(by: UIEdgeInsets(top: -6, left: -6, bottom: -6, right: -6)),
                in: textField
            )
            textField.accessibilityFrame = frame
        }
    }
    
}
