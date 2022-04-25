//
//  PhotosVM+Share
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/26/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import LinkPresentation
import Photos
import UIKit

extension UIViewController {
    func share(photos: [Photo], model: PhotosViewModel) {
        let assets = photos.map { $0.asset }

        Task {
            var urls = [URL?]()
            await withTaskGroup(of: URL?.self) { group in

                for asset in assets {
                    group.addTask {
                        let url = await asset.getURL()
                        return url
                    }
                }
                for await url in group {
                    urls.append(url)
                }
            }

            let dataSource = PhotosSharingDataSource(model: model, assets: assets)
            let items = urls as [Any] + [dataSource]

            let starActivity = StarActivity { [weak model] in
                guard let model = model else { return }
                model.star(photos: photos)

                if model.slidesState == nil {
                    model.updateAfterStarChange()
                    model.stopSelecting?()
                } else {
                    if let photo = model.slidesState?.currentPhoto {
                        model.configureToolbar(for: photo)
                    }
                    model.sortNeededAfterStarChanged = true
                }
            }

            let ignoreActivity = IgnoreActivity { [weak model] in
                guard let model = model else { return }
                model.ignore(photos: photos)

                if model.slidesState == nil {
                    model.stopSelecting?()
                }
            }
            presentShareSheet(items: items, applicationActivities: [starActivity, ignoreActivity])
        }
    }
}

class StarActivity: UIActivity {
    var tapped: (() -> Void)?
    init(tapped: (() -> Void)?) {
        self.tapped = tapped
    }

    override var activityTitle: String? { "Star" }
    override var activityType: UIActivity.ActivityType? { UIActivity.ActivityType("Star") }
    override var activityImage: UIImage? { UIImage(systemName: "star") }
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        true
    }

    override class var activityCategory: UIActivity.Category { .action }
    override func prepare(withActivityItems activityItems: [Any]) {}

    override func perform() {
        tapped?()
    }
}

class IgnoreActivity: UIActivity {
    var tapped: (() -> Void)?
    init(tapped: (() -> Void)?) {
        self.tapped = tapped
    }

    override var activityTitle: String? { "Ignore" }
    override var activityType: UIActivity.ActivityType? { UIActivity.ActivityType("Ignore") }
    override var activityImage: UIImage? { UIImage(systemName: "nosign") }
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        true
    }

    override class var activityCategory: UIActivity.Category { .action }
    override func prepare(withActivityItems activityItems: [Any]) {}

    override func perform() {
        tapped?()
    }
}

class PhotosSharingDataSource: NSObject, UIActivityItemSource {
    let model: PhotosViewModel
    let assets: [PHAsset]
    var previewImage: UIImage?

    init(model: PhotosViewModel, assets: [PHAsset]) {
        self.model = model
        self.assets = assets
        super.init()

        if let firstAsset = assets.first {
            model.getSmallImage(from: firstAsset, targetSize: CGSize(width: 200, height: 200)) { [weak self] image in
                self?.previewImage = image
            }
        }
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return ""
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return nil
    }

    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        guard let image = previewImage else { return nil }
        let imageProvider = NSItemProvider(object: image)
        let metadata = LPLinkMetadata()
        metadata.imageProvider = imageProvider

        if assets.count == 1 {
            if let firstAsset = assets.first, let originalFilename = firstAsset.originalFilename {
                metadata.title = originalFilename
            }
        } else {
            metadata.title = "\(assets.count) Photos"
        }
        return metadata
    }
}

extension PHAsset {
    func getURL() async -> URL? {
        if mediaType == .image {
            let options: PHContentEditingInputRequestOptions = .init()
            options.canHandleAdjustmentData = { _ in true }
            return await withCheckedContinuation { continuation in
                requestContentEditingInput(with: options) { contentEditingInput, _ in
                    if let contentEditingInput = contentEditingInput {
                        let url = contentEditingInput.fullSizeImageURL as URL?
                        continuation.resume(returning: url)
                    } else {
                        continuation.resume(returning: nil)
                    }
                }
            }
        }
        return nil
    }
}
