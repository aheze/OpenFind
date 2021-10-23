//
//  VC+SearchCollectionView.swift
//  SearchBar
//
//  Created by Zheng on 10/14/21.
//

import UIKit

extension SearchViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fields.count + 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? SearchFieldCell else { return UICollectionViewCell() }
        
        if let field = fields[safe: indexPath.item] {
            cell.textChanged = { [weak self] text in
                self?.fields[indexPath.item].value = .string(text)
                self?.fields[indexPath.item].fieldHuggingWidth = self?.getFieldHuggingWidth(fieldText: text) ?? 0
            }
            
            let fieldText = field.getText()
            cell.textField.text = fieldText
        } else {
//            cell.textField.text = "Add Word"
//            print("NO!!!!!!!!!!")
        }
        
        return cell
    }
    
    func widthOfExpandedCell(for index: Int) -> Double {
        
        var extraPadding = CGFloat(0)

        if index == 0 {
            extraPadding += Constants.sidePadding /// if **left edge**, add side padding
        } else {
            extraPadding += Constants.sidePeekPadding
        }
        
        if index == fields.count - 2 || index == fields.count - 1 {
            extraPadding += Constants.sidePadding /// if **right edge**, add side padding
        } else {
            extraPadding += Constants.sidePeekPadding
        }
        
        let fullWidth = searchCollectionView.frame.width
        return fullWidth - extraPadding
    }
    
    func getFieldHuggingWidth(fieldText: String) -> CGFloat {
        let textWidth = fieldText.width(withConstrainedHeight: 10, font: Constants.fieldFont)
        let leftPaddingWidth = Constants.fieldBaseViewLeftPadding
        let rightPaddingWidth = Constants.fieldBaseViewRightPadding
        let textPadding = 2 * Constants.fieldTextSidePadding
//        let leftViewWidth = Constants.fieldLeftViewWidth
//        let rightViewWidth = Constants.fieldRightViewWidth
        return textWidth + leftPaddingWidth + rightPaddingWidth + textPadding
    }
}

extension String {
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}
