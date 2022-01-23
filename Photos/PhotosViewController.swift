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
    
    
    @IBAction func selectPressed(_ sender: Any) {
        if toolbarViewModel?.toolbar != nil {
            toolbarViewModel?.toolbar = nil
        } else {
            toolbarViewModel?.toolbar = AnyView(selectionToolbar)
        }
    }

    @IBAction func addPressed(_ sender: Any) {
        photosSelectionViewModel.selectedCount += 1
    }

    @IBAction func minusPressed(_ sender: Any) {
        photosSelectionViewModel.selectedCount -= 1
    }
    
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
}

