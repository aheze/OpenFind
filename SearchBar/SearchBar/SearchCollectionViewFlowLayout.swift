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
        
        
        let fullCellWidth = getCellWidth?() ?? 0
        for index in widths.indices {
            let cellOffset = CGFloat(index) * fullCellWidth
//            print("Offset: \(cellOffset)")
            
            if cellOffset > contentOffset { /// cell is not yet approached
                let indexPath = IndexPath(item: index, section: 0)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(x: cellOffset, y: 0, width: fullCellWidth, height: Constants.cellHeight)
                
                layoutAttributes.append(attributes)
            } else {
                let differenceBetweenContentOffsetAndCell = min(fullCellWidth, contentOffset - cellOffset)
                
                let percentage = differenceBetweenContentOffsetAndCell / fullCellWidth
                if index == 1 {
                    print("Percentage: \(percentage)")
                }
                let shiftingOffset = percentage * (max(0, fullCellWidth - widths[index]))
                
                
                let indexPath = IndexPath(item: index, section: 0)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(x: cellOffset + shiftingOffset, y: 0, width: fullCellWidth - shiftingOffset, height: Constants.cellHeight)
                
                layoutAttributes.append(attributes)
            }
            
        }
        contentSize.height = Constants.cellHeight
        contentSize.width = CGFloat(widths.count) * fullCellWidth
        
        print("Content: \(contentSize)")
        self.contentSize = contentSize
            
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
            
            
            
            
            
            
            
        
        
        
        
    }
    
    /// boilerplate code
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool { return true }
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
        return context
    }
    
    
}
