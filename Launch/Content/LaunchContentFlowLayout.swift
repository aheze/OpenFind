//
//  LaunchContentFlowLayout.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

class LaunchContentFlowLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
    }
    
    /// get data
    var getPages: (() -> [LaunchPageIdentifier])?
    
    var getCollectionViewWidth: (() -> CGFloat)?
    
    var currentIndexChanged: (() -> Void)?
    
    var layoutAttributes = [UICollectionViewLayoutAttributes]()

    /// calculated from `getTargetOffset`
    var currentIndex = 0 {
        didSet {
            currentIndexChanged?()
        }
    }
    
    var contentSize = CGSize.zero /// the scrollable content size of the collection view
    override var collectionViewContentSize: CGSize { return contentSize } /// pass scrollable content size back to the collection view
    
    /// pass attributes to the collection view flow layout
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributes[safe: indexPath.item]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        /// edge cells don't shrink, but the animation is perfect
        return layoutAttributes.filter { rect.intersects($0.frame) } /// try deleting this line
    }
    
    override func prepare() { /// configure the cells' frames
        super.prepare()
        
        guard let collectionView = collectionView else { return }
     
        let width = getCollectionViewWidth?() ?? collectionView.bounds.width
        let height = collectionView.bounds.height
        
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        /// current origin of a page
        var currentOrigin = CGFloat(0)
        
        guard let pages = getPages?() else { return }
        for index in pages.indices {
            let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: index, section: 0))
            let rect = CGRect(x: currentOrigin, y: 0, width: width, height: height)
            attributes.frame = rect
            layoutAttributes.append(attributes)
            
            currentOrigin += width
        }

        contentSize = CGSize(width: currentOrigin, height: height)
        
        self.layoutAttributes = layoutAttributes
    }
    
    /// boilerplate code
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool { return true }
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        let boundsChanged = newBounds.size != collectionView?.bounds.size
        context.invalidateFlowLayoutAttributes = boundsChanged
        context.invalidateFlowLayoutDelegateMetrics = boundsChanged
        return context
    }
    
    /// called upon finger lift
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        return getTargetOffset(for: proposedContentOffset, velocity: velocity.x)
    }
    
    /// called after rotation
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        prepare()
        let attributes = layoutAttributes[safe: currentIndex]
        return CGPoint(x: attributes?.frame.origin.x ?? proposedContentOffset.x, y: 0)
    }
    
    func getTargetOffset(for point: CGPoint, velocity: CGFloat) -> CGPoint {
        let proposedOffset = point.x

        var pickedAttributes = [UICollectionViewLayoutAttributes?]()
        
        switch velocity {
        case _ where velocity < 0:
            pickedAttributes = layoutAttributes.map { layoutAttribute in
                let isCandidate = layoutAttribute.frame.origin.x <= proposedOffset
                return isCandidate ? layoutAttribute : nil
            }
        case _ where velocity > 0:
            pickedAttributes = layoutAttributes.map { layoutAttribute in
                let isCandidate = layoutAttribute.frame.origin.x >= proposedOffset
                return isCandidate ? layoutAttribute : nil
            }
        default:
            pickedAttributes = layoutAttributes
        }
        
        /// find closest origin
        var (closestAttribute, closestAttributeIndex, closestDistance): (UICollectionViewLayoutAttributes?, Int, CGFloat) = (nil, 0, CGFloat.infinity)
        for (index, attribute) in pickedAttributes.enumerated() {
            if let layoutAttribute = attribute {
                let distance = abs(layoutAttribute.frame.origin.x - proposedOffset)
                if distance < closestDistance {
                    closestAttributeIndex = index
                    closestAttribute = layoutAttribute
                    closestDistance = distance /// for keeping track later
                }
            }
        }
        
        currentIndex = closestAttributeIndex
        return CGPoint(x: closestAttribute?.frame.origin.x ?? point.x, y: 0)
    }
}
