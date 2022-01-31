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
    var searchViewModel: SearchViewModel
    
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
        model: ListsDetailViewModel,
        toolbarViewModel: ToolbarViewModel,
        searchViewModel: SearchViewModel
    ) {
        self.model = model
        self.toolbarViewModel = toolbarViewModel
        self.searchViewModel = searchViewModel
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
        
        baseSearchBarOffset = getCompactBarSafeAreaHeight(with: Global.safeAreaInsets)
        additionalSearchBarOffset = 0
        
        scrollView.contentInset.top = searchViewModel.getTotalHeight()
        scrollView.verticalScrollIndicatorInsets.top = searchViewModel.getTotalHeight() + SearchNavigationConstants.scrollIndicatorTopPadding
        scrollView.delegate = self
        
        headerTopCenterTextField.delegate = self
        headerBottomTextField.delegate = self
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
    
    func boundsChanged(to size: CGSize, safeAreaInsets: UIEdgeInsets) {
        baseSearchBarOffset = getCompactBarSafeAreaHeight(with: safeAreaInsets)
        updateSearchBarOffset?()
    }
}

/// Scroll view
extension ListsDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = -scrollView.contentOffset.y
        additionalSearchBarOffset = contentOffset - baseSearchBarOffset - searchViewModel.getTotalHeight()
        updateSearchBarOffset?()
    }
}

extension ListsDetailViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if
            let text = textField.text,
            let textRange = Range(range, in: text)
        {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            
            if textField == headerTopCenterTextField {
                model.list.name = updatedText
            } else if textField == headerBottomTextField {
                model.list.desc = updatedText
            }
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
