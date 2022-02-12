//
//  PhotosViewController.swift
//  Photos
//
//  Created by Zheng on 11/18/21.
//

import SwiftUI

class PhotosViewController: UIViewController, PageViewController {
    var tabType: TabState = .photos
    var toolbarViewModel: ToolbarViewModel?
    
    var photosSelectionViewModel = PhotosSelectionViewModel()
    lazy var selectionToolbar = PhotosSelectionToolbarView(model: photosSelectionViewModel)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension PhotosViewController {
    func willBecomeActive() {}
    
    func didBecomeActive() {}
    
    func willBecomeInactive() {
        withAnimation {
            toolbarViewModel?.toolbar = nil
        }
    }
    
    func didBecomeInactive() {}
    
    func boundsChanged(to size: CGSize, safeAreaInset: UIEdgeInsets) {
        
    }
}

