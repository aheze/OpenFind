//
//  SettingsResultsViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import SwiftUI

class SettingsResultsViewController: UIViewController {
    let paths: [[SettingsRow]]

    var contentViewHeightC: NSLayoutConstraint?
    var contentViewBottomC: NSLayoutConstraint? /// set this to active/inactive when showing/hiding results
    
    lazy var contentView: UIView = {
        let contentView = UIView()
        view.addSubview(contentView)
        let contentViewHeightC = contentView.heightAnchor.constraint(equalToConstant: 100)
        let contentViewBottomC = contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor) /// allow autoresizing
        contentViewBottomC.priority = .init(rawValue: 756)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.leftAnchor.constraint(equalTo: view.leftAnchor),
            contentView.rightAnchor.constraint(equalTo: view.rightAnchor),
            contentViewBottomC,
            contentViewHeightC
        ])
        self.contentViewHeightC = contentViewHeightC
        self.contentViewBottomC = contentViewBottomC
        return contentView
    }()

    init(paths: [[SettingsRow]]) {
        self.paths = paths
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        /**
         Instantiate the base `view`.
         */
        view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        
        _ = contentView

        let settingsResultsView = SettingsResultsView(paths: paths) { [weak self] size in
            print("size: \(size)")
            self?.contentViewHeightC?.constant = size.height
        }

        let hostingController = UIHostingController(rootView: settingsResultsView)
        hostingController.view.frame = view.bounds
        hostingController.view.backgroundColor = .clear
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        addChildViewController(hostingController, in: contentView)
    }
}
