//
//  Bridge.swift
//  TabBarController
//
//  Created by Zheng on 10/28/21.
//


import UIKit

public struct Bridge {
    public static var viewController: (() -> TabBarViewController) = {
        let bundle = Bundle(identifier: "com.aheze.TabBarController")
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        let viewController = storyboard.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
            
        return viewController
    }
}
