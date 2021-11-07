//
//  TabBarVC+Datasource.swift
//  TabBarController
//
//  Created by Zheng on 11/2/21.
//

import UIKit

extension TabBarViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? ContentCell else { return UICollectionViewCell() }
        
        let page = pages[indexPath.item]
        
//        switch tab {
//        case .photos:
//            cell.backgroundColor = .green
//        case .camera:
//            cell.backgroundColor = .blue
//        case .lists:
//            cell.backgroundColor = .yellow
//        default:
//            fatalError()
//        }
        
        
        return cell
    }
}


//extension ViewController: ChildControllersManagerDelegate {
//    typealias ViewControllerType = MyVC
//
//    func willAdd(_ childViewController: MyVC, at index: Int) {
//         print("Will add! \(childViewController).. \(index)")
//    }
//}
//
//protocol ChildControllersManagerDelegate: class {
//    associatedtype ViewControllerType: UIViewController
//    func willAdd(_ childViewController: ViewControllerType, at index: Int)
//}
//
//final class ChildControllersManager<V, D: ChildControllersManagerDelegate> where D.ViewControllerType == V {
//    private var viewControllers = [Int: V]()
//    weak var delegate: D?
//
//    func addChild(at index: Int, to viewController: UIViewController, displayIn contentView: UIView) {
//        let childVC: V
//        if let vc = viewControllers[index] {
//            print("Using cached view controller")
//            childVC = vc
//        } else {
//            print("Creating new view controller")
//            childVC = V()
//            viewControllers[index] = childVC
//        }
//
//        delegate?.willAdd(childVC, at: index)
//
//        viewController.addChild(childVC)
//        childVC.view.frame = contentView.bounds
//        contentView.addSubview(childVC.view)
//        childVC.didMove(toParent: viewController)
//    }
//
//    func remove(at index: Int) {
//        print("Remove at \(index)")
//        guard let vc = viewControllers[index] else { return }
//        vc.willMove(toParent: nil)
//        vc.view.removeFromSuperview()
//        vc.removeFromParent()
//    }
//
//    func cleanCachedViewControllers(index: Int) {
//        let indexesToClean = viewControllers.keys.filter { key in
//            key > index + 1 || key < index - 1
//        }
//        indexesToClean.forEach {
//            viewControllers[$0] = nil
//        }
//    }
//}
//
//
