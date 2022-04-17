//
//  ListsDetailViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Popovers
import SwiftUI

class ListsDetailViewController: UIViewController, Searchable, NavigationNamed {
    var model: ListsDetailViewModel
    var tabViewModel: TabViewModel
    var toolbarViewModel: ToolbarViewModel
    var realmModel: RealmModel
    
    var name: NavigationName? = .listsDetail
    
    /// Searchable
    var showSearchBar = false
    var baseSearchBarOffset = CGFloat(0)
    var additionalSearchBarOffset: CGFloat? = CGFloat(0)
    var updateSearchBarOffset: (() -> Void)?
    
    /// backported menu
    var popoversOptionsButton: UIButton?
    var popoversMenu: Templates.UIKitMenu? /// if under iOS 14, this will contain the popovers menu.
    
    @IBOutlet var scrollView: ListsDetailScrollView!
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
    lazy var iconPicker = IconPickerController(model: headerTopLeftIconPickerModel, realmModel: realmModel)
    
    @IBOutlet var headerTopCenterView: UIView!
    @IBOutlet var headerTopCenterTextField: UITextField!
    
    @IBOutlet var headerTopRightView: ButtonView!
    @IBOutlet var headerTopRightViewLeftC: NSLayoutConstraint!
    lazy var headerTopRightColorPickerModel = ColorPickerViewModel(selectedColor: UIColor(hex: model.list.color))

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
    
    @IBOutlet var bottomSpacerView: UIView!
    
    @IBOutlet var bottomSpacerHeightC: NSLayoutConstraint!
    
    /// for copy/delete
    lazy var toolbarView = ListsDetailToolbarView(model: model)
    
    /// for keyboard navigation
    var wordsKeyboardToolbarViewModel = WordsKeyboardToolbarViewModel()
    lazy var wordsKeyboardToolbarViewController = WordsKeyboardToolbarViewController(model: wordsKeyboardToolbarViewModel)
    
    init?(
        coder: NSCoder,
        model: ListsDetailViewModel,
        tabViewModel: TabViewModel,
        toolbarViewModel: ToolbarViewModel,
        realmModel: RealmModel
    ) {
        self.model = model
        self.tabViewModel = tabViewModel
        self.toolbarViewModel = toolbarViewModel
        self.realmModel = realmModel
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
        listenToKeyboard()
        listenToWordsToolbar()
        updateWordsKeyboardToolbar()
        
        baseSearchBarOffset = getCompactBarSafeAreaHeight(with: Global.safeAreaInsets)
        additionalSearchBarOffset = 0
        
        scrollView.verticalScrollIndicatorInsets.top = SearchNavigationConstants.scrollIndicatorTopPadding
        scrollView.delegate = self
        
        headerTopCenterTextField.delegate = self
        headerBottomTextField.delegate = self
        
        /// when the Add Words button was pressed
        if model.focusFirstWord {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let firstCell = self.wordsTableView.cellForRow(at: 0.indexPath) as? ListsDetailWordCell {
                    firstCell.textField.becomeFirstResponder()
                }
            }
        }
        
        bottomSpacerHeightC.constant = 0
        bottomSpacerView.alpha = 0
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        
        print("Moving to \(parent)")
        
        if parent == nil {
            /// add the chip views one last time
            model.listUpdated?(model.list.getList(), true) /// `final` is true, reload the lists back in the collection view
        }
        
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
        
        updateSwipeBackTouchTarget(viewSize: view.bounds.size)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        model.isEditing = false
        model.isEditingChanged?()
        tabViewModel.excludedFrames[.listsDetailsScreenEdge] = nil
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        loadListContents()
    }
}
