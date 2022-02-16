//
//  Protocols.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/10/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

protocol DismissalNavigationLifecycle: UIViewController {
    func willAppear()
    func didAppear()
    func willDisappear()
    func didDisappear()
}

protocol Searchable: UIViewController {
    var baseSearchBarOffset: CGFloat { get set }
    var additionalSearchBarOffset: CGFloat? { get set }
}
