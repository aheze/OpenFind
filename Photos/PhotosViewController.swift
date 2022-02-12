//
//  PhotosViewController.swift
//  Photos
//
//  Created by Zheng on 11/18/21.
//

import SwiftUI

class PhotosViewController: UIViewController, PageViewController, Searchable {
    
    var tabType: TabState = .photos
    var toolbarViewModel: ToolbarViewModel?
    
    var baseSearchBarOffset = CGFloat(0)
    var additionalSearchBarOffset = CGFloat(0)
    
    var photosSelectionViewModel = PhotosSelectionViewModel()
    lazy var selectionToolbar = PhotosSelectionToolbarView(model: photosSelectionViewModel)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}


