import UIKit
import SwiftUI

/// Check if both SwiftUI and Combine is available. Without this
/// xcodebuild fails, saying it can't find the SwiftUI types used
/// inside PageView, even though it's wrapped with an @available
/// check. Found a possible fix here: https://stackoverflow.com/questions/58233454/how-to-use-swiftui-in-framework
/// This might be related to the issue discussed in this thread:
/// https://forums.swift.org/t/weak-linking-of-frameworks-with-greater-deployment-targets/26017/24
#if canImport(SwiftUI) && canImport(Combine)

/// `PageView` provides a SwiftUI wrapper around `PagingViewController`.
/// It can be used with any fixed array of `PagingItem`s. Use the
/// `PagingOptions` struct to customize the properties.
@available(iOS 13.0, *)
public struct PageView<Item: PagingItem, Page: View>: View {
  private let items: [Item]
  private let options: PagingOptions
  private let content: (Item) -> Page
  
  /// Initialize a new `PageView`.
  ///
  /// - Parameters:
  ///   - options: The configuration parameters we want to customize.
  ///   - items: The array of `PagingItem`s to display in the menu.
  ///   - content: A callback that returns the `View` for each item.
  public init(
    options: PagingOptions = PagingOptions(),
    items: [Item],
    content: @escaping (Item) -> Page) {
    self.options = options
    self.items = items
    self.content = content
  }
  
  public var body: some View {
    PagingController(
      items: items,
      options: options,
      content: content)
  }
  
  struct PagingController: UIViewControllerRepresentable {
    let items: [Item]
    let options: PagingOptions
    let content: (Item) -> Page
    
    func makeCoordinator() -> Coordinator {
      Coordinator(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<PagingController>) -> PagingViewController {
      let pagingViewController = PagingViewController(options: options)
      return pagingViewController
    }
    
    func updateUIViewController(_ pagingViewController: PagingViewController, context: UIViewControllerRepresentableContext<PagingController>) {
      context.coordinator.parent = self
      
      if pagingViewController.dataSource == nil {
        pagingViewController.dataSource = context.coordinator
      } else {
        pagingViewController.reloadData()
      }
    }
  }

  class Coordinator: PagingViewControllerDataSource {
    var parent: PagingController
    
    init(_ pagingController: PagingController) {
      self.parent = pagingController
    }
    
    func numberOfViewControllers(in pagingViewController: PagingViewController) -> Int {
      return parent.items.count
    }
    
    func pagingViewController(_: PagingViewController, viewControllerAt index: Int) -> UIViewController {
      let view = parent.content(parent.items[index])
      return UIHostingController(rootView: view)
    }
    
    func pagingViewController(_: PagingViewController, pagingItemAt index: Int) -> PagingItem {
      return parent.items[index]
    }
  }
}
#endif
