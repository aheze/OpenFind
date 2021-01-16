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
    @IBOutlet weak var promptLabel: UILabel!
    
    // MARK: Match to color
    var matchToColors = [String: [CGColor]]()
    
    // MARK: Find from cache
    var numberCurrentlyFindingFromCache = 0 /// how many cache findings are currently going on
    
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
    
}
