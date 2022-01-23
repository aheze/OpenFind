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
    var searchConfiguration: SearchConfiguration
    
    var baseSearchBarOffset = CGFloat(0)
    var additionalSearchBarOffset = CGFloat(0)
    var updateSearchBarOffset: (() -> Void)?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    /// has padding on the sides
    @IBOutlet weak var containerStackView: UIStackView!
    @IBOutlet weak var containerViewTopC: NSLayoutConstraint!
    @IBOutlet weak var containerViewRightC: NSLayoutConstraint!
    @IBOutlet weak var containerViewBottomC: NSLayoutConstraint!
    @IBOutlet weak var containerViewLeftC: NSLayoutConstraint!
    
    // MARK: - Header
    
    @IBOutlet weak var headerView: UIView!
    
    /// surrounds the inner views
    @IBOutlet weak var headerStackView: UIStackView!
    
    /// **top**
    @IBOutlet weak var headerTopView: UIView!
    @IBOutlet weak var headerTopViewHeightC: NSLayoutConstraint!

    @IBOutlet weak var headerTopLeftView: ButtonView!
    @IBOutlet weak var headerTopLeftViewRightC: NSLayoutConstraint!
    @IBOutlet weak var headerTopLeftImageView: UIImageView!
    
    @IBOutlet weak var headerTopCenterView: UIView!
    @IBOutlet weak var headerTopCenterTextField: UITextField!
    
    @IBOutlet weak var headerTopRightView: ButtonView!
    @IBOutlet weak var headerTopRightViewLeftC: NSLayoutConstraint!
    var headerTopRightColorPickerModel = ColorPickerViewModel()

    /// **bottom**
    @IBOutlet weak var headerBottomView: UIView!
    @IBOutlet weak var headerBottomViewHeightC: NSLayoutConstraint!
    @IBOutlet weak var headerBottomTextField: UITextField!
    
    
    
    // MARK: - Words
    @IBOutlet weak var wordsView: UIView!

    /// **top**
    @IBOutlet weak var wordsTopView: UIView!
    
    @IBOutlet weak var wordsTopLeftView: ButtonView!
    @IBOutlet weak var wordsTopLeftLabel: PaddedLabel!
    
    @IBOutlet weak var wordsTopCenterView: ButtonView!
    @IBOutlet weak var wordsTopCenterLabel: PaddedLabel!
    
    @IBOutlet weak var wordsTopRightView: ButtonView!
    @IBOutlet weak var wordsTopRightImageView: UIImageView!
    @IBOutlet weak var wordsTopRightImageViewLeftC: NSLayoutConstraint!
    @IBOutlet weak var wordsTopRightImageViewRightC: NSLayoutConstraint!
    
    
    /// **table view**
    @IBOutlet weak var wordsTableView: UITableView!
    @IBOutlet weak var wordsTableViewHeightC: NSLayoutConstraint!
    
    init?(
        coder: NSCoder,
        list: List,
        searchConfiguration: SearchConfiguration
    ) {
        self.model = ListsDetailViewModel(list: list)
        self.searchConfiguration = searchConfiguration
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "List"
        navigationItem.largeTitleDisplayMode = .never
        
        setup()
        
        baseSearchBarOffset = getCompactBarSafeAreaHeight()
        
        scrollView.contentInset.top = searchConfiguration.getTotalHeight()
        scrollView.verticalScrollIndicatorInsets.top = searchConfiguration.getTotalHeight() + SearchNavigationConstants.scrollIndicatorTopPadding
        
        scrollView.delegate = self
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
