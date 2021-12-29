//
//  NavigationViewModifier.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/28/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
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
                    navBarAppearance.configureWithDefaultBackground()
                    navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
                    navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
                
                    navBarAppearance.backgroundColor = UIColor.black.withAlphaComponent(0.9)
                    viewController.navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
                
                    viewController.navigationController?.navigationBar.standardAppearance = navBarAppearance
                
                    viewController.navigationController?.navigationBar.barTintColor = UIColor.black.withAlphaComponent(0.9)
                    viewController.navigationController?.navigationBar.tintColor = UIColor.white
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
