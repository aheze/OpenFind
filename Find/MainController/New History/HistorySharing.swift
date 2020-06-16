////
////  HistorySharing.swift
////  Find
////
////  Created by Zheng on 4/17/20.
////  Copyright © 2020 Andrew. All rights reserved.
////

import UIKit

class HistorySharing: UIActivityItemProvider {
    let temporaryURL: URL
    let filePath: String
    var folderURL: URL
    
    init(filePath: String, folderURL: URL) {
        self.folderURL = folderURL
        self.filePath = filePath
        let newUrl = URL(fileURLWithPath: NSTemporaryDirectory() + "\(filePath).jpg")
        self.temporaryURL = newUrl
        do {
            let data = Data()
            try data.write(to: temporaryURL)
        } catch let error {
            print("error saving file with error", error)
        }
//        print("URLstempSTART: \(temporaryURL)")
        super.init(placeholderItem: temporaryURL)
    }
    
    override var item: Any {
        get {
//            print("GET ITEM")
            let newFileUrl = folderURL.appendingPathComponent(filePath)
            do {
                let data = try Data(contentsOf: newFileUrl)
                try data.write(to: temporaryURL)
            } catch let error {
                print("error saving file with error", error)
            }
            return temporaryURL
        }
    }
    
}



//class HistorySharing: UIActivityItemProvider {
//    let temporaryURLs: [URL]
//    let imageModels: [HistoryModel]
//    var folderURL: URL
//
//    init(imageModels: [HistoryModel], folderURL: URL) {
//        self.folderURL = folderURL
//        self.imageModels = imageModels
//        var paths = [URL]()
//        for model in imageModels {
//            let newUrl = URL(fileURLWithPath: NSTemporaryDirectory() + "\(model.filePath).jpeg")
//            paths.append(newUrl)
//        }
//        self.temporaryURLs = paths
//        print("URLstempSTART: \(temporaryURLs)")
//        super.init(placeholderItem: temporaryURLs)
////        placeholderItem = UIImage()
//        print("URLstemp: \(temporaryURLs)")
//    }
//
////    func activityViewControllerPlaceholderItem(activityViewController: UIActivityViewController) -> AnyObject {
////        print("place")
////        return UIImage()
////    }
////    func activityViewControllerPlaceholderItem(activityViewController: UIActivityViewController) -> AnyObject {
////        return NSString(string: placeholder)
////    }
////
////    func activityViewController(activityViewController: UIActivityViewController, itemForActivityType activityType: String) -> AnyObject? {
////        if activityType == UIActivityTypeMessage {
////            return NSString(string: alternate)
////        } else {
////            return NSString(string: placeholder)
////        }
////    }
//
//    override var item: Any {
//        get {
//            print("GET ITEM")
////            let recipeDocument = RecipeDocument(fileURL: temporaryURL)
////            recipeDocument.load(recipe: recipe)
////
////            let data = try? recipeDocument.contents(forType: "com.recipe")
////            try? recipeDocument.writeContents(data, andAttributes: nil, safelyTo: temporaryURL, for: .forCreating)
//            for (index, tempURL) in temporaryURLs.enumerated() {
//                print("URL")
//                let model = imageModels[index]
//                let newFileUrl = folderURL.appendingPathComponent(model.filePath)
////                guard let data = url.jpegData(compressionQuality: 1) else { return temporaryURLs }
////                let newUrl
////                if let image = url.loadImageFromDocumentDirectory() {
//                    do {
////                        try image.write(to: url)
//                        let data = try Data(contentsOf: newFileUrl)
//                        print("data;| \(data)")
//                        try data.write(to: tempURL, options: .completeFileProtection)
//                    } catch let error {
//                        print("error saving file with error", error)
//                    }
////                }
//            }
//            return temporaryURLs
//        }
//    }
//
//}
