import Foundation

public enum PagingDirection {
  case reverse
  case forward
  case none
}

extension PagingDirection {
  
  var pageViewControllerNavigationDirection: EMPageViewControllerNavigationDirection {
    switch self {
    case .forward, .none:
      return .forward
    case .reverse:
      return .reverse
    }
  }
  
}
