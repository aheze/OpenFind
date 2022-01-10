//
//  ViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/9/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

class ViewController: UIViewController {

    var searchNavigationController: SearchNavigationController!
    let configuration = SearchConfiguration.lists
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewControllerStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = viewControllerStoryboard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
        viewController.configuration = configuration
        viewController.updateNavigationBar = { [weak self] in
            self?.searchNavigationController?.updateSearchBarOffset()
        }
        
        viewController.view.backgroundColor = .secondarySystemBackground
        
        let storyboard = UIStoryboard(name: "SearchNavigationContent", bundle: nil)
        let searchNavigationController = storyboard.instantiateViewController(identifier: "SearchNavigationController") { coder in
            SearchNavigationController(
                coder: coder,
                rootViewController: viewController,
                searchConfiguration: self.configuration
            )
        }
        
        self.searchNavigationController = searchNavigationController
        addChildViewController(searchNavigationController, in: view)

    }

}

class MainViewController: UIViewController, UIScrollViewDelegate, Searchable {
    
    var searchBarOffset = CGFloat(0)
    var configuration: SearchConfiguration!
    var updateNavigationBar: (() -> Void)?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBAction func buttonPressed(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        viewController.configuration = configuration
        viewController.updateNavigationBar = { [weak self] in
            self?.updateNavigationBar?()
        }
        
        navigationController?.pushViewController(viewController, animated: true)
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Main"
        scrollView.delegate = self
        scrollView.contentInset.top = configuration.getTotalHeight()
//        contentView.addDebugBorders(.blue)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset: CGFloat
        
        let offset = abs(min(0, scrollView.contentOffset.y))
        let topSafeArea = scrollView.adjustedContentInset.top
        
        /// rubber banding on large title
        if offset > topSafeArea {
            contentOffset = offset
        } else {
            contentOffset = topSafeArea
        }
        
        searchBarOffset = contentOffset - configuration.getTotalHeight()
        updateNavigationBar?()
    }
}

class DetailViewController: UIViewController, Searchable {

    var searchBarOffset = CGFloat(0)
    var configuration: SearchConfiguration!
    var updateNavigationBar: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Detail"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .secondarySystemBackground
        
        let topInset = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
        let barHeight = navigationController?.navigationBar.getCompactHeight() ?? 0
        
        searchBarOffset = topInset + barHeight
    }

}

