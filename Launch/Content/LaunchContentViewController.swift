//
//  LaunchContentViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

class LaunchContentViewController: UIViewController {
    var model: LaunchViewModel
    @IBOutlet var collectionView: UICollectionView!

    static func make(model: LaunchViewModel) -> LaunchContentViewController {
        let storyboard = UIStoryboard(name: "LaunchContent", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "LaunchContentViewController") { coder in
            LaunchContentViewController(
                coder: coder,
                model: model
            )
        }
        return viewController
    }

    init?(coder: NSCoder, model: LaunchViewModel) {
        self.model = model
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("You must create this view controller with metadata.")
    }
}
