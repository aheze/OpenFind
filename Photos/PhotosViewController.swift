//
//  PhotosViewController.swift
//  Photos
//
//  Created by Zheng on 11/18/21.
//

import SwiftUI

class PhotosViewController: UIViewController, PageViewController {
    
    var tabType: TabState = .photos
    var photosSelectionViewModel: ToolbarViewModel.PhotosSelection!
    
    lazy var selectionToolbar: PhotosSelectionToolbarView = {
        return PhotosSelectionToolbarView(viewModel: photosSelectionViewModel)
    }()
    
    var getActiveToolbarViewModel: (() -> ToolbarViewModel)?
    
    /// active, animate
    var activateSelectionToolbar: ((Bool, Bool) -> Void)?
    
    
    @IBAction func selectPressed(_ sender: Any) {
        if let activeToolbarViewModel = getActiveToolbarViewModel?() {
            if activeToolbarViewModel.toolbar == .photosSelection {
                self.activateSelectionToolbar?(false, false)
            } else {
                self.activateSelectionToolbar?(true, false)
            }
        }
    }
    @IBAction func addPressed(_ sender: Any) {
        print("add pressed")
        photosSelectionViewModel.selectedCount += 1
    }
    @IBAction func minusPressed(_ sender: Any) {
        print("mnus pressed")
        photosSelectionViewModel.selectedCount -= 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Photos loaded")
        
        self.photosSelectionViewModel = .init()
    }
}

extension PhotosViewController {
    func willBecomeActive() {
        
    }
    
    func didBecomeActive() {
        
    }
    
    func willBecomeInactive() {
//        print("Becoming inactve.")
        self.activateSelectionToolbar?(false, true)
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
            .disabled(viewModel.selectedCount == 0)
            
            Text("\(viewModel.selectedCount) Photos Selected")
                .font(.system(.headline))
                .frame(maxWidth: .infinity)
            
            ToolbarIconButton(iconName: "trash") {
            }
            .disabled(viewModel.selectedCount == 0)
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
