//
//  ImagePickerList.swift
//  Find
//
//  Created by Andrew on 1/28/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

class ImagePickerList: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var bottomToggle: UISegmentedControl!
    @IBAction func bottomToggleChanged(_ sender: Any) {
        switch bottomToggle.selectedSegmentIndex {
        case 0:
            print(bottomToggle.selectedSegmentIndex)
        case 1:
            print(bottomToggle.selectedSegmentIndex)
        case 2:
            print(bottomToggle.selectedSegmentIndex)
        case 3:
            print(bottomToggle.selectedSegmentIndex)
        case 4:
            print(bottomToggle.selectedSegmentIndex)
        case 5:
            print(bottomToggle.selectedSegmentIndex)
        case 6:
            print(bottomToggle.selectedSegmentIndex)
        case 7:
            print(bottomToggle.selectedSegmentIndex)
        case 8:
            print(bottomToggle.selectedSegmentIndex)
            
        default:
            print("wrong segment")
        }
    }
    
    
    @IBOutlet weak var topToggle: UISegmentedControl!
    
    @IBAction func topToggleChanged(_ sender: Any) {
    }
    
    @IBOutlet weak var imageContainer: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var sfSymbolArray: [String] = [String]()
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    init() {
        super.init(frame: .zero)
        setUp()
    }
    private func setUp() {
       // fromNib()
        //self.changeNumberDelegate = self
        
        Bundle.main.loadNibNamed("ImagePickerList", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        populateSymbolArray()
        clipsToBounds = true
        layer.cornerRadius = 10
        layer.backgroundColor = #colorLiteral(red: 0, green: 0.5981545251, blue: 0.937254902, alpha: 1)
        imageContainer.clipsToBounds = true
        imageContainer.layer.cornerRadius = 10
        imageContainer.layer.borderWidth = 8
        imageContainer.layer.borderColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        collectionView.register(SymbolCell.self, forCellWithReuseIdentifier: "SymbolCellID")
        collectionView.register(SupHeadView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SupHeadID")
        collectionView.delegate = self
        collectionView.dataSource = self
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        collectionView?.contentInset = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        
    }
    
    
    
}

extension ImagePickerList {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, indexPath: IndexPath) -> UICollectionReusableView {
        var reusableView : UICollectionReusableView? = nil

        // Create header
        if (kind == UICollectionView.elementKindSectionHeader) {
            // Create Header
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SupHeadID", for: indexPath) as! SupHeadView
            headerView.frame = CGRect(x: 0, y: 0, width: 25, height: collectionView.frame.size.height)
print("secti")
            reusableView = headerView
        }
        return reusableView!
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sfSymbolArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SymbolCellID", for: indexPath) as! SymbolCell
        
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 55, weight: .semibold)
        let name = sfSymbolArray[indexPath.item]
        let newImage = UIImage(systemName: name, withConfiguration: symbolConfiguration)?.withTintColor(.black, renderingMode: .alwaysOriginal)
        
        
        cell.imageView.image = newImage
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSize = (collectionView.frame.height - (collectionView.contentInset.top + collectionView.contentInset.bottom)) / 8
    return CGSize(width: itemSize, height: itemSize)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    
    
}
class SymbolCell: UICollectionViewCell {

    //static var identifier: String = "SymbolCellID"

    weak var imageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)

//        let textLabel = UILabel(frame: .zero)
//        textLabel.translatesAutoresizingMaskIntoConstraints = false
//        self.contentView.addSubview(textLabel)
//        NSLayoutConstraint.activate([
//            self.contentView.centerXAnchor.constraint(equalTo: textLabel.centerXAnchor),
//            self.contentView.centerYAnchor.constraint(equalTo: textLabel.centerYAnchor),
//        ])
//
//
//        self.textLabel = textLabel
//        self.reset()
        let imageV = UIImageView()
        self.contentView.addSubview(imageV)
        imageV.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.imageView = imageV
        self.imageView.contentMode = .scaleAspectFit
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    override func prepareForReuse() {
//        super.prepareForReuse()
//        self.reset()
//    }
//
//    func reset() {
////        self.textLabel.textAlignment = .center
//    }
}
class SupHeadView: UICollectionReusableView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.myCustomInit()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.myCustomInit()
    }

    func myCustomInit() {
        print("hello there from SupView")
    }

}

