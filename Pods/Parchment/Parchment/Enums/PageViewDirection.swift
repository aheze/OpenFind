import Foundation
import CoreGraphics

public enum PageViewDirection {
  case forward
  case reverse
  case none
  
  init(from direction: PagingDirection) {
    switch direction {
    case .forward:
      self = .forward
    case .reverse:
      self = .reverse
    case .none:
      self = .none
    }
  }
  
  init(progress: CGFloat) {
    if progress > 0 {
      self = .forward
    } else if progress < 0 {
      self = .reverse
    } else {
      self = .none
    }
  }
}
