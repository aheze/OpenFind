//
//  BasicSetup.swift
//  Find
//
//  Created by Andrew on 10/13/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

extension StatsViewController {
    func setupNavigationBar() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithDefaultBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        
        navBarAppearance.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        
        navigationController?.navigationBar.barTintColor = UIColor.black.withAlphaComponent(0.9)
        navigationController?.navigationBar.tintColor = UIColor.white
    }
}

