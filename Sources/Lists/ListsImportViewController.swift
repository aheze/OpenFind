//
//  ListsImportViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/30/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

enum ListsImportConstants {
    static var titleFont = UIFont.preferredCustomFont(forTextStyle: .headline, weight: .medium)
    static var headerPadding = UIEdgeInsets(top: 14, left: 32, bottom: 14, right: 32)
    
    static var buttonFont = UIFont.preferredCustomFont(forTextStyle: .title3, weight: .medium)
    static var labelInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
    static var labelPadding = CGFloat(16)
    static var importButtonPadding = UIEdgeInsets(top: 14, left: 24, bottom: 14, right: 24)
}

class ListsImportViewController: UIViewController {
    let list: List
    var onImport: (() -> Void)?

    var listsContentView: ListsContentView!
    var widthC: NSLayoutConstraint!
    var heightC: NSLayoutConstraint!

    var size = CGSize.zero
    var chipFrames = [ListFrame.ChipFrame]()

    init(list: List, onImport: (() -> Void)?) {
        self.list = list
        self.onImport = onImport
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
        view.backgroundColor = .secondarySystemBackground
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem.menuButton(self, action: #selector(dismissSelf), imageName: "Dismiss")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        UIView.performWithoutAnimation {
            self.layout()
        }
    }

    func getSizes() {
        let availableWidth = view.bounds.width - (ListsCollectionConstants.sidePadding * 2)
        let (size, chipFrames, _) = list.getDisplayData(availableWidth: availableWidth)
        self.size = size
        self.chipFrames = chipFrames
    }

    func layout() {
        getSizes()

        widthC.constant = size.width
        heightC.constant = size.height
        listsContentView.addChipViews(with: list, chipFrames: chipFrames)
    }

    func setup() {
        let listsContentView = ListsContentView()
        view.addSubview(listsContentView)
        listsContentView.translatesAutoresizingMaskIntoConstraints = false
        let widthC = listsContentView.widthAnchor.constraint(equalToConstant: 100)
        let heightC = listsContentView.heightAnchor.constraint(equalToConstant: 100)

        NSLayoutConstraint.activate([
            listsContentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            listsContentView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            widthC,
            heightC
        ])

        listsContentView.configureData(list: list)
        listsContentView.configureSelection(selected: false, modelSelecting: false)

        /// set after selection
        listsContentView.isUserInteractionEnabled = false

        self.listsContentView = listsContentView
        self.widthC = widthC
        self.heightC = heightC

        
        // MARK: Title
        let titleLabel = UILabel()
        titleLabel.text = "Would you like to import this list?"
        titleLabel.textColor = .secondaryLabel
        titleLabel.font = ListsImportConstants.titleFont
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: ListsImportConstants.headerPadding.top),
            titleLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -ListsImportConstants.headerPadding.right),
            titleLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: ListsImportConstants.headerPadding.left)
        ])
        
        // MARK: Bottom button
        let imageView = UIImageView(image: UIImage(systemName: "square.and.arrow.down"))
        let buttonLabel = UILabel()

        buttonLabel.text = "Import List"
        buttonLabel.textColor = Colors.accent
        buttonLabel.font = ListsImportConstants.buttonFont
        imageView.setIconFont(font: ListsImportConstants.buttonFont)
        imageView.tintColor = Colors.accent

        let stackView = UIStackView(arrangedSubviews: [imageView, buttonLabel])
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        stackView.isUserInteractionEnabled = false

        let buttonView = ButtonView()
        buttonView.backgroundColor = Colors.accent.withAlphaComponent(0.1)
        buttonView.clipsToBounds = true
        buttonView.layer.cornerRadius = 12
        buttonView.tapped = { [weak self] in
            self?.importTapped()
        }

        view.addSubview(buttonView)
        buttonView.addSubview(stackView)
        stackView.pinEdgesToSuperview(padding: ListsImportConstants.importButtonPadding)
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -ListsImportConstants.labelPadding)
        ])
    }

    @objc func importTapped() {
        onImport?()
        dismissSelf()
    }

    @objc func dismissSelf() {
        dismiss(animated: true)
    }
}
