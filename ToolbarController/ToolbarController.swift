//
//  ToolbarController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Combine
import SwiftUI

/// for controllers with a toolbar
class ToolbarController: UIViewController {
    var model: ToolbarViewModel
    var rootViewController: UIViewController

    @IBOutlet var containerView: UIView!
    @IBOutlet var toolbarContainerViewContainer: UIView! /// contains blur, extends into safe area
    @IBOutlet var toolbarContainerView: UIView!

    static func make(model: ToolbarViewModel, rootViewController: UIViewController) -> ToolbarController {
        let storyboard = UIStoryboard(name: "ToolbarContent", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "ToolbarController") { coder in
            ToolbarController(
                coder: coder,
                model: model,
                rootViewController: rootViewController
            )
        }
        return viewController
    }

    init?(coder: NSCoder, model: ToolbarViewModel, rootViewController: UIViewController) {
        self.model = model
        self.rootViewController = rootViewController
        super.init(coder: coder)
    }

    var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        addChildViewController(rootViewController, in: containerView)

        let toolbarView = ToolbarView(model: model)
        let hostingController = UIHostingController(rootView: toolbarView)

        addChildViewController(hostingController, in: toolbarContainerView)

        hostingController.view.backgroundColor = .clear
        toolbarContainerViewContainer.backgroundColor = .clear
        toolbarContainerView.backgroundColor = .clear

        model.$toolbar.sink { [weak self] toolbar in

            guard let self = self else { return }
            UIView.animate(withDuration: 0.3) {
                if toolbar != nil {
                    self.toolbarContainerView.alpha = 1
                } else {
                    self.toolbarContainerView.alpha = 0
                }
            }
        }
        .store(in: &cancellables)

        presentationController?.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("You must create this view controller with metadata.")
    }
}

extension ToolbarController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        print("presentationControllerDidDismiss dismiss!")
        model.didDismiss?()
    }
}
