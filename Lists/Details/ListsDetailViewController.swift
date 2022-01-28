//
//  ListsDetailViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

class ListsDetailViewController: UIViewController, Searchable {
    var model: ListsDetailViewModel
    var toolbarViewModel: ToolbarViewModel
    var searchConfiguration: SearchConfiguration
    
    var baseSearchBarOffset = CGFloat(0)
    var additionalSearchBarOffset = CGFloat(0)
    var updateSearchBarOffset: (() -> Void)?
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    
    /// has padding on the sides
    @IBOutlet var containerStackView: UIStackView!
    @IBOutlet var containerViewTopC: NSLayoutConstraint!
    @IBOutlet var containerViewRightC: NSLayoutConstraint!
    @IBOutlet var containerViewBottomC: NSLayoutConstraint!
    @IBOutlet var containerViewLeftC: NSLayoutConstraint!
    
    // MARK: - Header
    
    @IBOutlet var headerView: UIView!
    
    /// surrounds the inner views
    @IBOutlet var headerStackView: UIStackView!
    
    /// **top**
    @IBOutlet var headerTopView: UIView!
    @IBOutlet var headerTopViewHeightC: NSLayoutConstraint!

    @IBOutlet var headerTopLeftView: ButtonView!
    @IBOutlet var headerTopLeftViewRightC: NSLayoutConstraint!
    @IBOutlet var headerTopLeftImageView: UIImageView!
    lazy var headerTopLeftIconPickerModel = IconPickerViewModel(selectedIcon: model.list.icon)
    lazy var iconPicker = IconPickerController(model: headerTopLeftIconPickerModel)
    
    @IBOutlet var headerTopCenterView: UIView!
    @IBOutlet var headerTopCenterTextField: UITextField!
    
    @IBOutlet var headerTopRightView: ButtonView!
    @IBOutlet var headerTopRightViewLeftC: NSLayoutConstraint!
    var headerTopRightColorPickerModel = ColorPickerViewModel()

    /// **bottom**
    @IBOutlet var headerBottomView: UIView!
    @IBOutlet var headerBottomViewHeightC: NSLayoutConstraint!
    @IBOutlet var headerBottomTextField: UITextField!
    
    // MARK: - Words

    @IBOutlet var wordsView: UIView!

    /// **top**
    @IBOutlet var wordsTopView: UIView!
    
    @IBOutlet var wordsTopLeftView: ButtonView!
    @IBOutlet var wordsTopLeftLabel: PaddedLabel!
    
    @IBOutlet var wordsTopCenterView: ButtonView!
    @IBOutlet var wordsTopCenterLabel: PaddedLabel!
    
    @IBOutlet var wordsTopRightView: ButtonView!
    @IBOutlet var wordsTopRightImageView: UIImageView!
    @IBOutlet var wordsTopRightImageViewLeftC: NSLayoutConstraint!
    @IBOutlet var wordsTopRightImageViewRightC: NSLayoutConstraint!
    
    /// **table view**
    @IBOutlet var wordsTableView: UITableView!
    @IBOutlet var wordsTableViewHeightC: NSLayoutConstraint!
    lazy var toolbarView = ListsDetailToolbarView(model: model)
    
    init?(
        coder: NSCoder,
        list: List,
        realmModel: RealmModel,
        toolbarViewModel: ToolbarViewModel,
        searchConfiguration: SearchConfiguration
    ) {
        self.model = ListsDetailViewModel(list: list, realmModel: realmModel)
        self.toolbarViewModel = toolbarViewModel
        self.searchConfiguration = searchConfiguration
        super.init(coder: coder)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "List"
        navigationItem.largeTitleDisplayMode = .never
        
        setup()
        listenToButtons()
        listenToModel()
        
        baseSearchBarOffset = getCompactBarSafeAreaHeight()
        additionalSearchBarOffset = 0
        
        scrollView.contentInset.top = searchConfiguration.getTotalHeight()
        scrollView.verticalScrollIndicatorInsets.top = searchConfiguration.getTotalHeight() + SearchNavigationConstants.scrollIndicatorTopPadding
        
        scrollView.delegate = self
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        
        withAnimation {
            toolbarViewModel.toolbar = nil
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isMovingToParent, model.isEditing {
            withAnimation {
                toolbarViewModel.toolbar = AnyView(toolbarView)
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        loadListContents()
    }
}

/// Scroll view
extension ListsDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = -scrollView.contentOffset.y
        additionalSearchBarOffset = contentOffset - baseSearchBarOffset - searchConfiguration.getTotalHeight()
        updateSearchBarOffset?()
    }
}
