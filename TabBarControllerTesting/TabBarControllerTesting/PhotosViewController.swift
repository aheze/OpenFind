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
    
    var getActiveToolbarViewModel: (() -> ToolbarViewModel)?
    var activateSelectionToolbar: ((Bool) -> Void)?
    
    @IBAction func button1Pressed(_ sender: Any) {
        if let activeToolbarViewModel = getActiveToolbarViewModel?() {
            if activeToolbarViewModel.toolbar == .photosSelection {
                self.activateSelectionToolbar?(false)
            } else {
                self.activateSelectionToolbar?(true)
            }
        }
    }
    @IBAction func button2Pressed(_ sender: Any) {
        /// add
        photosSelectionViewModel.selectedCount += 1
    }
    @IBAction func button3Pressed(_ sender: Any) {
        /// subtract
        photosSelectionViewModel.selectedCount -= 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Photos loaded")
        
    }
}

extension PhotosViewController {
    func willBecomeActive() {
        
    }
    
    func didBecomeActive() {
        
    }
    
    func willBecomeInactive() {
        self.activateSelectionToolbar?(false)
    }
    
    func didBecomeInactive() {
        
    }
}

struct PhotosSelectionToolbarView: View {
    @ObservedObject var viewModel: ToolbarViewModel.PhotosSelection
    
    var body: some View {
        HStack {
            ToolbarIconButton(iconName: viewModel.starOn ? "star.fill" : "star") {
                viewModel.starOn.toggle()
            }
            
            Text("\(viewModel.selectedCount) Photos Selected")
                .font(.system(.headline))
            .frame(maxWidth: .infinity)
            
            ToolbarIconButton(iconName: "trash") {
            }
        }
    }
}
struct ToolbarIconButton: View {
    var iconName: String
    var action: (() -> Void)
    var body: some View {
        Button(action: action) {
            Image(systemName: iconName)
                .font(Font(Constants.iconFont))
        }
    }
}
