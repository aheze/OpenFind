//
//  SupportDocsView+Search.swift
//  SupportDocsSwiftUI
//
//  Created by Zheng on 11/28/20.
//

import SwiftUI

/**
 View Modifier for applying the search bar.
 */
internal struct SearchBarModifier: ViewModifier {
    
    var searchBarConfigurator: SearchBarConfigurator
    
    func body(content: Content) -> some View {
        content
        .overlay(
            ViewControllerResolver { viewController in
                viewController.navigationItem.searchController = self.searchBarConfigurator.searchController
            }
            .frame(width: 0, height: 0)
        )
    }
}

/**
 Extension to make applying the View Modifier easier..
 */
extension View {
    func add(_ searchBarConfigurator: SearchBarConfigurator) -> some View {
        return self.modifier(SearchBarModifier(searchBarConfigurator: searchBarConfigurator))
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
    
    func updateUIViewController(_ uiViewController: ParentResolverViewController, context: Context) { }
}

internal class ParentResolverViewController: UIViewController {
    
    let onResolve: (UIViewController) -> Void
    
    init(onResolve: @escaping (UIViewController) -> Void) {
        self.onResolve = onResolve
        super.init(nibName: nil, bundle: nil)
    }
    
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
