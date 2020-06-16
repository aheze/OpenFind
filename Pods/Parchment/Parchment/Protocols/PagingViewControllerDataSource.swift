import UIKit

/// The `PagingViewControllerDataSource` protocol is used to provide
/// the `PagingItem` you want to display and which view controller it
/// is associated with. Using this data sources requires you to have a
/// fixed number of view controllers.
///
/// In order for these methods to be called, you first need to set the
/// initial `PagingItem` by calling `select(pagingItem:)` on
/// `PagingViewController`.
public protocol PagingViewControllerDataSource: class {
  
  /// Return the total number of view controllers
  ///
  /// - Parameter pagingViewController: The `PagingViewController`
  /// instance
  /// - Returns: The number of view controllers
  func numberOfViewControllers<T>(
    in pagingViewController: PagingViewController<T>) -> Int
  
  /// Return the view controller accociated with a given index. This
  /// method is only called for the currently selected `PagingItem`,
  /// and its two possible siblings.
  ///
  /// - Parameter pagingViewController: The `PagingViewController`
  /// instance
  /// - Parameter index: The index of a given `PagingItem`
  /// - Returns: The view controller for the given index
  func pagingViewController<T>(
    _ pagingViewController: PagingViewController<T>,
    viewControllerForIndex index: Int) -> UIViewController
  
  /// Return the `PagingItem` instance for a given index
  ///
  /// - Parameter pagingViewController: The `PagingViewController`
  /// instance
  /// - Returns: The `PagingItem` instance
  func pagingViewController<T>(
    _ pagingViewController: PagingViewController<T>,
    pagingItemForIndex index: Int) -> T
}
