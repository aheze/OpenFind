//
//  PhotoFindViewController.swift
//  Find
//
//  Created by Zheng on 1/15/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

class PhotoFindViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var warningView: UIView! /// ocr search in progress
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var findPhotos = [FindPhoto]() /// photos to find from
    var findModels = [FindModel]() /// photos displayed in table view
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Load")
    }
    
}
