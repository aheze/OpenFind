import Foundation

public protocol PagingMenuDelegate: AnyObject {
    func selectContent(pagingItem: PagingItem, direction: PagingDirection, animated: Bool)
    func removeContent()
}
