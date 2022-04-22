//
//  NavigationView.swift
//  FindAppClip1
//
//  Created by Zheng on 3/13/21.
//

import SwiftUI

/**
 ViewModifier that applies SupportOptions' `NavigationBar` and `SearchBar` configurations.
 */
struct BarModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .overlay( /// Workaround to apply the `ViewControllerResolver`
                ViewControllerResolver { viewController in
                
                    /**
                     Now set the Navigation Bar's configuration
                     */
                    let navBarAppearance = UINavigationBarAppearance()
                    navBarAppearance.configureWithOpaqueBackground()
                    navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
                    navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
                
                    navBarAppearance.backgroundColor = UIColor(named: "DarkBackground")
                
                    viewController.navigationController?.navigationBar.standardAppearance = navBarAppearance
                
                    viewController.navigationController?.navigationBar.barTintColor = UIColor(named: "DarkBackground")
                    viewController.navigationController?.navigationBar.tintColor = UIColor.white
                
                    if let navController = viewController.navigationController {
                        navController.navigationBar.layer.masksToBounds = false
                        navController.navigationBar.layer.shadowColor = UIColor(named: "DarkBackground")?.cgColor
                        navController.navigationBar.layer.shadowOpacity = 0.8
                        navController.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2.0)
                        navController.navigationBar.layer.shadowRadius = 6
                    }
                }
                .frame(width: 0, height: 0)
            )
    }
}

/**
 For easier usage of the bar modifier.
 */
extension View {
    func configureBar() -> some View {
        return modifier(BarModifier())
    }
}

/**
 Access the parent view controller of the SwiftUI View.
 */
internal final class ViewControllerResolver: UIViewControllerRepresentable {
    /// Closure to call when `didMove`
    let onResolve: (UIViewController) -> Void
        
    init(onResolve: @escaping (UIViewController) -> Void) {
        self.onResolve = onResolve
    }
    
    func makeUIViewController(context: Context) -> ParentResolverViewController {
        ParentResolverViewController(onResolve: onResolve)
    }
    
    func updateUIViewController(_ uiViewController: ParentResolverViewController, context: Context) {}
}

internal class ParentResolverViewController: UIViewController {
    let onResolve: (UIViewController) -> Void
    
    init(onResolve: @escaping (UIViewController) -> Void) {
        self.onResolve = onResolve
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(onResolve:) to instantiate ParentResolverViewController.")
    }
        
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        
        if let parent = parent {
            onResolve(parent)
        }
    }
}

extension UIColor {
    /// Converts this `UIColor` instance to a 1x1 `UIImage` instance and returns it.
    ///
    /// - Returns: `self` as a 1x1 `UIImage`.
    func as1ptImage() -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        setFill()
        UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return image
    }
}

