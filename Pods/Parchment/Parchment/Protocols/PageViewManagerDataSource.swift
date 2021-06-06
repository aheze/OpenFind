import UIKit

protocol PageViewManagerDataSource: class {
  func viewControllerBefore(_ viewController: UIViewController) -> UIViewController?
  func viewControllerAfter(_ viewController: UIViewController) -> UIViewController?
}
