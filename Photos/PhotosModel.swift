//
//  PhotosModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/14/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Photos
import UIKit

struct PhotosSlidesState {
    var viewController: PhotosSlidesViewController?
    var findPhotos: [FindPhoto]
    var startingPhoto: Photo
    var currentIndex: Int?

    /// get from `findPhotos`
    func getFindPhotoIndex(photo: FindPhoto) -> Int? {
        if let firstIndex = findPhotos.firstIndex(of: photo) {
            return firstIndex
        }
        return nil
    }
}

struct PhotosResultsState {
    var findPhotos: [FindPhoto]

    /// get from `findPhotos`
    func getFindPhotoIndex(photo: FindPhoto) -> Int? {
        if let firstIndex = findPhotos.firstIndex(of: photo) {
            return firstIndex
        }
        return nil
    }
}

struct FindPhoto: Hashable {
    var photo: Photo
    var thumbnail: UIImage?
    var fullImage: UIImage?
    var associatedViewController: PhotosSlidesItemViewController?
}

struct PhotosSection: Hashable {
    var title: String
    var categorization: Categorization
    var photos = [Photo]()

    func hash(into hasher: inout Hasher) {
        hasher.combine(categorization)
    }

    static func == (lhs: PhotosSection, rhs: PhotosSection) -> Bool {
        lhs.categorization == rhs.categorization
    }

    enum Categorization: Equatable, Hashable {
        case date(year: Int, month: Int, day: Int)

        func getTitle() -> String {
            switch self {
            case .date(let year, let month, let day):
                let dateComponents = DateComponents(year: year, month: month, day: day)
                if let date = Calendar.current.date(from: dateComponents) {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MMM d, yyyy"
                    let string = formatter.string(from: date)
                    return string
                }
            }

            return ""
        }
    }
}
