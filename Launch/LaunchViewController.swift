//
//  LaunchViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Combine
import RealityKit
import SwiftUI

class LaunchViewController: UIViewController {
    var model: LaunchViewModel

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var activityIndicatorTopC: NSLayoutConstraint!

    @IBOutlet var sceneContainer: UIView!
    lazy var sceneView: ARView? = ARView()
    var baseEntity: ModelEntity?
    var camera: PerspectiveCamera?

    /// for SwiftUI, respects safe area
    @IBOutlet var contentContainer: UIView!

    // MARK: - Listen to these values

    var entering: (() -> Void)? /// called when just about to show the main content
    var done: (() -> Void)?

    static func make(model: LaunchViewModel) -> LaunchViewController {
        let storyboard = UIStoryboard(name: "LaunchContent", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "LaunchViewController") { coder in
            LaunchViewController(
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

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        sceneContainer.layoutIfNeeded()
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
