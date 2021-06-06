import Foundation
import UIKit

class PagingSizeCache {
  
  var options: PagingOptions
  var implementsSizeDelegate: Bool = false
  var sizeForPagingItem: ((PagingItem, Bool) -> CGFloat?)?
  
  private var sizeCache: [Int: CGFloat] = [:]
  private var selectedSizeCache: [Int: CGFloat] = [:]
  
  init(options: PagingOptions) {
    self.options = options
    
    #if swift(>=4.2)
    let didEnterBackground = UIApplication.didEnterBackgroundNotification
    let didReceiveMemoryWarning = UIApplication.didReceiveMemoryWarningNotification
    #else
    let didEnterBackground = NSNotification.Name.UIApplicationDidEnterBackground
    let didReceiveMemoryWarning = NSNotification.Name.UIApplicationDidReceiveMemoryWarning
    #endif
    
    NotificationCenter.default.addObserver(self,
      selector: #selector(applicationDidEnterBackground(notification:)),
      name: didEnterBackground,
      object: nil)
    
    NotificationCenter.default.addObserver(self,
      selector: #selector(didReceiveMemoryWarning(notification:)),
      name: didReceiveMemoryWarning,
      object: nil)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  func clear() {
    self.sizeCache =  [:]
    self.selectedSizeCache = [:]
  }
  
  func itemSize(for pagingItem: PagingItem) -> CGFloat {
    if let size = sizeCache[pagingItem.identifier] {
      return size
    } else {
      let size = sizeForPagingItem?(pagingItem, false)
      sizeCache[pagingItem.identifier] = size
      return size ?? options.estimatedItemWidth
    }
  }
  
  func itemWidthSelected(for pagingItem: PagingItem) -> CGFloat {
    if let size = selectedSizeCache[pagingItem.identifier] {
      return size
    } else {
      let size = sizeForPagingItem?(pagingItem, true)
      selectedSizeCache[pagingItem.identifier] = size
      return size ?? options.estimatedItemWidth
    }
  }
  
  @objc private func didReceiveMemoryWarning(notification: NSNotification) {
    self.clear()
  }
  
  @objc private func applicationDidEnterBackground(notification: NSNotification) {
    self.clear()
  }
  
}
