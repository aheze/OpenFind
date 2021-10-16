//
//  VC+SearchCollectionView.swift
//  SearchBar
//
//  Created by Zheng on 10/14/21.
//

import UIKit

extension SearchViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fields.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let field = fields[indexPath.item]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? SearchFieldCell else { return UICollectionViewCell() }
        
        
        cell.textChanged = { [weak self] text in
            
            self?.fields[indexPath.item].value = .string(text)
            self?.fields[indexPath.item].valueFrameWidth = self?.calculateFrameWidth(text: text) ?? 0
            
        }
        
        let fieldText = field.getText()
        cell.textField.text = fieldText
        
        return cell
    }
    
    func widthOfExpandedCell(for index: Int) -> Double {
        
        var extraPadding = CGFloat(0)
        if index != 0 {
            extraPadding += Constants.sidePeekPadding
        }
        if index != fields.count - 1 {
            extraPadding += Constants.sidePeekPadding
        }
        
        let fullWidth = searchCollectionView.frame.width
        return fullWidth - extraPadding
    }
    
    func calculateFrameWidth(text: String) -> CGFloat {
        return text.width(withConstrainedHeight: 10, font: Constants.fieldFont) + 30
    }
}

extension String {
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}
