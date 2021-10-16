//
//  SearchCollectionViewFlowLayout.swift
//  SearchBar
//
//  Created by Zheng on 10/14/21.
//

import UIKit



class SearchCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
    }
    
    var getFields: (() -> [Field])?
    var getCellWidth: (() -> CGFloat)?
    
    var preparedOnce: Bool = false
    
    var layoutAttributes = [UICollectionViewLayoutAttributes]() /// store the frame of each item
    var contentSize = CGSize.zero /// the scrollable content size of the collection view
    override var collectionViewContentSize: CGSize { return contentSize } /// pass scrollable content size back to the collection view
    
    /// pass attributes to the collection view flow layout
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributes[indexPath.item]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        /// edge cells don't shrink, but the animation is perfect
        return layoutAttributes.filter { rect.intersects($0.frame) } /// try deleting this line
        
    }
    
    
    /// make the layout (strip vs list) here
    override func prepare() { /// configure the cells' frames
        super.prepare()
        
        
        guard let collectionView = collectionView else { return }
        
        
        layoutAttributes = []
        
        var contentSize = CGSize.zero
        var offset: CGPoint = .zero /// origin for each cell
        
        guard let fields = getFields?() else { return }
//        print("Field widths: \(fields.map { $0.valueFrameWidth })")
        
        let widths = fields.map { $0.valueFrameWidth }
        let contentOffset = collectionView.contentOffset.x
        
//        print("ContnetOffset: \(collectionView.contentOffset.x)")
        
        let focusedIndex = widths.enumerated().min( by: { abs($0.1 - contentOffset) < abs($1.1 - contentOffset) } )!
        
        
        
        for index in widths.indices {
            let width = widths[index]
            
            
            let previousWidth = widths[safe: index - 1] ?? width
            let nextWidth = widths[safe: index + 1] ?? width
            
            let totalWidth = widths[0...index].reduce(0, +)
            let previousTotalWidth = totalWidth - previousWidth
            let nextTotalWidth = totalWidth + nextWidth
            
//            if contentOffset < totalWidth { /// hasn't reached cell yet
//                if index == 1 {
//                    //                    print("NOT REAch")
//
////                    print("Width: \(totalWidth)")
//                    /// 0 to this number
//                    let range = totalWidth - previousTotalWidth
//                    let zeroedContentOffset = contentOffset - previousTotalWidth
//
//                    //                ^cv
//                    // 0000000 OOOOOOOOOOOOO   OOOOOOO
//                    // to...
//                    //         ^cv
//                    // OOOOOOOOOOOOO   OOOOOOO
//
//
//
//                    let percentageFull = zeroedContentOffset / range
//                    let difference = (getCellWidth?() ?? 0) - width
//
//                    print("percentageFull: \(percentageFull)")
//                    print("Diff: \(difference)")
//
//                    let indexPath = IndexPath(item: index, section: 0)
//                    let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
//                    attributes.frame = CGRect(x: offset.x, y: 0, width: width + difference * percentageFull, height: Constants.cellHeight)
//
//                    layoutAttributes.append(attributes)
//
//                    continue
////                    let indexPath = IndexPath(item: index, section: 0)
////                    let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
//////                    attributes.frame =
////                    layoutAttributes.append(attributes)
////                    continue
//
//
////                    print("Offset: \(zeroedContentOffset) / \(range)")
//                }
//
//            } else { /// already reached cell
//                //                if index == 1 {
//                //                    print("reached!")
//                //                }
//            }
            
            
            
            
            let indexPath = IndexPath(item: index, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = CGRect(x: offset.x, y: 0, width: width, height: Constants.cellHeight)
            
            layoutAttributes.append(attributes)
            
            
            print("Total width: \(totalWidth)")
//            print("Prev: \(previousTotalWidth)")
//            print("Next: \(nextTotalWidth)")
            
            offset.x += width
            if index == widths.indices.count - 1 {
                contentSize.height = Constants.cellHeight
                contentSize.width = offset.x
                
                print("Content: \(contentSize)")
                self.contentSize = contentSize
            }
        }
        
        
        
//        for itemIndex in 0..<collectionView.numberOfItems(inSection: 0) {
//            let cellSize = CGSize(width: getCellWidth?() ?? 300, height: 48)
//            contentSize.height = cellSize.height
//
//            let indexPath = IndexPath(item: itemIndex, section: 0)
//            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
//
//            attributes.frame = CGRect(origin: offset, size: cellSize)
//            layoutAttributes.append(attributes)
//
//            let addedOffset = cellSize.width
//            offset.x += addedOffset
//        }
        
        
//        contentSize.width += offset.x
//        contentSize.height += offset.y
//        self.contentSize = contentSize
    }
    
    /// boilerplate code
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool { return true }
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
        return context
    }
    
    
    //    func reset(){
    //        preparedOnce = false
    //    }
    
}
