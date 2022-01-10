//
//  ViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/9/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

class ViewController: UIViewController {

    weak var delegate: SearchNavigationUpdater?
    let configuration = SearchConfiguration.lists
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let topPadding = self.configuration.getTotalHeight()
        
        let viewControllerStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = viewControllerStoryboard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
        viewController.topInset = topPadding
        viewController.scrolled = { [weak self] scrollView in
            guard let self = self else { return }
            let contentOffset: CGFloat
//            = -(scrollView.contentOffset.y + topPadding)
            
            let offset = abs(min(0, scrollView.contentOffset.y))
            let topSafeArea = scrollView.adjustedContentInset.top
            
            /// rubber banding on large title
            if offset > topSafeArea {
                contentOffset = offset
            } else {
                contentOffset = topSafeArea
            }
            self.delegate?.updateSearchBarOffset(offset: contentOffset - topPadding)
        }
        viewController.view.backgroundColor = .secondarySystemBackground
        
        let storyboard = UIStoryboard(name: "SearchNavigationContent", bundle: nil)
        let navigationController = storyboard.instantiateViewController(identifier: "SearchNavigationController") { coder in
            SearchNavigationController(
                coder: coder,
                rootViewController: viewController,
                searchConfiguration: self.configuration
            )
        }
        
        
        delegate = navigationController
        addChildViewController(navigationController, in: view)

    }

}

class MainViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    var topInset: CGFloat!
    @IBAction func buttonPressed(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    var scrolled: ((UIScrollView) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Main"
        scrollView.delegate = self
        scrollView.contentInset.top = topInset
        
        view.backgroundColor = UIColor.green
        
    }
    
    
    

    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrolled?(scrollView)
    }
}

class DetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Detail"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .secondarySystemBackground
        
    }

}

