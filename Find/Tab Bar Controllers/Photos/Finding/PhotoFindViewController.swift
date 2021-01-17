//
//  PhotoFindViewController.swift
//  Find
//
//  Created by Zheng on 1/15/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

class PhotoFindViewController: UIViewController {
    
    // MARK: Find bar
    @IBOutlet weak var findBar: FindBar!
    @IBOutlet var promptView: UIView!
    @IBOutlet weak var promptLabel: UILabel!
    
    // MARK: Finding
    var matchToColors = [String: [CGColor]]()
    var currentFilter = PhotoFilter.all
    var findingFromAllPhotos = false /// if finding from all photos in filter
    
    // MARK: Find from cache
    var numberCurrentlyFindingFromCache = 0 /// how many cache findings are currently going on
    var deviceWidth = UIScreen.main.bounds.width
    
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var warningView: UIView! /// ocr search in progress
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    var shouldAllowPressRow = false
    
    var findPhotos = [FindPhoto]() /// photos to find from
    var resultPhotos = [ResultPhoto]() /// photos displayed in table view
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Load")
        
        setup()
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
    }
    
}
