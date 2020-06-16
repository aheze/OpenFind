import Foundation

/// Used to be able to initialize a layout based on the type defined
/// in the menuLayoutClass property.
protocol PagingLayout {
  init(options: PagingOptions)
}

func createLayout<T>(layout: T.Type, options: PagingOptions) -> T where T: PagingLayout {
  return layout.init(options: options)
}
