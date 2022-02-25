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
    var startingFindPhoto: FindPhoto
    var currentIndex: Int?

    /// get from `findPhotos`
    func getFindPhotoIndex(photo: FindPhoto) -> Int? {
        if let firstIndex = findPhotos.firstIndex(where: { $0.photo == photo.photo }){
            return firstIndex
        }
        return nil
    }
}

struct PhotosResultsState {
    var findPhotos: [FindPhoto]
    var displayedIndices = Set<Int>()
//    {
//        didSet {
//            let newIndices = displayedIndices
//            let oldIndices = oldValue
//            let removedIndices = oldIndices.subtracting(newIndices)
//            print("Removed: \(removedIndices). New: \(newIndices), old: \(oldIndices)")
//        }
//    }

    /// get from `findPhotos`
    func getFindPhotoIndex(photo: FindPhoto) -> Int? {
        if let firstIndex = findPhotos.firstIndex(where: { $0.photo == photo.photo }) {
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
//    var cellHighlightsViewController: HighlightsViewController?

    /// results
    var highlights: Set<Highlight>?
    var descriptionText = ""
    var descriptionLines = [Line]()

    struct Line: Hashable {
        var string: String
        var lineHighlights: Set<LineHighlight>? /// the frames of these highlights will be relative to the result cell

        struct LineHighlight: Hashable {
            /**
             from the start index to the end index

                Example: "Safari" - searching for "a"
                    1..<2
                    3..<4
             */
            var rangeInSentence: Range<Int>
            var colors: [UIColor]
            var alpha: CGFloat
        }
    }
}

extension FindPhoto {
    func dateString() -> String {
        if let string = self.photo.asset.creationDate?.convertDateToReadableString() {
            return string
        } else {
            return "2022"
        }
    }
    
    func resultsString() -> String {
        let string: String
        let count = highlights?.count ?? 0
        if count == 1 {
            string = "\(count) Result"
        } else {
            string = "\(count) Results"
        }
        return string
    }
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
