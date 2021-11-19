//
//  ViewController.swift
//  Photos
//
//  Created by Zheng on 11/18/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    lazy var photos: PhotosController = {
        return PhotosBridge.makeController()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(photos.viewController, in: view)
    }
}

