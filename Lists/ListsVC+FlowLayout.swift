//
//  ListsVC+FlowLayout.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

extension ListsViewController {
    func createFlowLayout() -> ListsCollectionFlowLayout {
        let flowLayout = ListsCollectionFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.getLists = { [weak self] in
            guard let self = self else { return [] }
            return self.listsViewModel.displayedLists.map { $0.list }
        }
        flowLayout.getListSizeFromWidth = { [weak self] (availableWidth, list, listIndex) in
            guard let self = self else { return .zero }
            return self.getCellSize(availableWidth: availableWidth, list: list, listIndex: listIndex)
        }
        
        collectionView.setCollectionViewLayout(flowLayout, animated: false)
        collectionView.contentInset.top = searchConfiguration.getTotalHeight()
        return flowLayout
    }
    
    func getCellSize(availableWidth: CGFloat, list: List, listIndex: Int) -> CGSize {
        let c = ListsCellConstants.self
        
        let headerHeight = c.headerTitleFont.lineHeight
        + c.headerEdgeInsets.top
        + c.headerEdgeInsets.bottom
        
        let contentWidth = availableWidth
        - c.contentEdgeInsets.left
        - c.contentEdgeInsets.right
        
        
        /// relative to content
        var offset = CGSize.zero
        var chipFrames = [ListFrame.ChipFrame]()
        var numberOfLines = 1
        
        /// return true if add word chip was added
        func addWordsLeftChipIfNecessary(currentIndex: Int, currentFrame: CGRect) -> Bool {
            guard numberOfLines == c.maxNumberOfChipLines else { return false }
            
            let wordsLeftAfterCurrent = list.contents.count - (currentIndex)
            let wordsLeftText = "+\(wordsLeftAfterCurrent)"
            let wordsLeftTextSize = c.chipFont.sizeOfString(wordsLeftText)
            let combinedWidth = currentFrame.width + c.chipSpacing + wordsLeftTextSize.width
            
            if combinedWidth > contentWidth {
                let wordsLeftFrame = CGRect(
                    x: currentFrame.origin.x,
                    y: currentFrame.origin.y,
                    width: wordsLeftTextSize.width + c.chipEdgeInsets.left + c.chipEdgeInsets.right,
                    height: wordsLeftTextSize.height + c.chipEdgeInsets.top + c.chipEdgeInsets.bottom
                )
                let wordsLeftChipFrame = ListFrame.ChipFrame(
                    frame: wordsLeftFrame,
                    string: wordsLeftText
                )
                chipFrames.append(wordsLeftChipFrame)
                
                return true
            }
            return false
        }
        
        for index in list.contents.indices {
            let word = list.contents[index]
            let size = c.chipFont.sizeOfString(word)
            
            let frame = CGRect(
                x: offset.width,
                y: offset.height,
                width: size.width + c.chipEdgeInsets.left + c.chipEdgeInsets.right,
                height: size.height + c.chipEdgeInsets.top + c.chipEdgeInsets.bottom
            )
            
            /// check if there's still space for the `+5` even after the frame
            guard !addWordsLeftChipIfNecessary(currentIndex: index, currentFrame: frame) else {
                break
            }
            
            if frame.maxX <= contentWidth {
                let chipFrame = ListFrame.ChipFrame(
                    frame: frame,
                    string: word
                )
                chipFrames.append(chipFrame)
                offset.width += frame.width + c.chipSpacing
            } else if numberOfLines < c.maxNumberOfChipLines { /// add a new line
                let updatedFrame = CGRect(
                    x: 0,
                    y: frame.height + c.chipSpacing,
                    width: frame.width,
                    height: frame.height
                )
                
                if !addWordsLeftChipIfNecessary(currentIndex: index, currentFrame: updatedFrame) {
                    let chipFrame = ListFrame.ChipFrame(
                        frame: updatedFrame,
                        string: word
                    )
                    chipFrames.append(chipFrame)
                    offset.width = frame.width + c.chipSpacing /// is the first chip in the new line
                    offset.height += updatedFrame.origin.y
                    numberOfLines += 1
                }
            }
        }
        
        let chipContainerHeight = offset.height + (chipFrames.last?.frame.height ?? 0)
        let containerHeight = chipContainerHeight
        + c.contentEdgeInsets.top
        + c.contentEdgeInsets.bottom
        
        let height = headerHeight + containerHeight
        listsViewModel.displayedLists[listIndex].frame.chipFrames = chipFrames
        
        return CGSize(width: availableWidth, height: height)
    }
}

