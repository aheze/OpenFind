//
//  SettingsPageViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

class SettingsPageViewController: UIViewController {
    var model: SettingsViewModel
    var page: SettingsPage

    var contentViewHeightC: NSLayoutConstraint?
    lazy var contentView: UIView = {
        let contentView = UIView()
        view.addSubview(contentView)
        let contentViewHeightC = contentView.heightAnchor.constraint(equalToConstant: 100)
        let contentViewBottomC = contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor) /// allow autoresizing
        contentViewBottomC.priority = .init(rawValue: 750)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.leftAnchor.constraint(equalTo: view.leftAnchor),
            contentView.rightAnchor.constraint(equalTo: view.rightAnchor),
            contentViewBottomC,
            contentViewHeightC
        ])
        self.contentViewHeightC = contentViewHeightC
        return contentView
    }()

    init(model: SettingsViewModel, page: SettingsPage) {
        self.model = model
        self.page = page
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        title = page.title
        /**
         Instantiate the base `view`.
         */
        view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        
        _ = contentView

        let settingsPageView = SettingsPageView(
            model: model,
            page: page
        ) { [weak self] size in
            self?.contentViewHeightC?.constant = size.height
        }

        let hostingController = UIHostingController(rootView: settingsPageView)
        hostingController.view.frame = view.bounds
        hostingController.view.backgroundColor = .clear
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        addChildViewController(hostingController, in: contentView)
    }
}
