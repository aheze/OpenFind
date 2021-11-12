//
//  PhotosViewController.swift
//  TabBarControllerTesting
//
//  Created by Zheng on 11/12/21.
//

import SwiftUI
import TabBarController

class PhotosViewController: UIViewController, PageViewController {
    var tabType: TabState = .photos
    var photosSelectionViewModel: ToolbarViewModel.PhotosSelection!
    
    lazy var selectionToolbar: PhotosSelectionToolbarView = {
        self.photosSelectionViewModel = .init()
        return PhotosSelectionToolbarView(viewModel: photosSelectionViewModel)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Photos loaded")
    }
}

struct PhotosSelectionToolbarView: View {
    @ObservedObject var viewModel: ToolbarViewModel.PhotosSelection
    
    var body: some View {
        HStack {
        }
    }
}
