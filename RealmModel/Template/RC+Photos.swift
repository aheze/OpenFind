//
//  RC+Photos.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/31/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension RealmContainer {
    func loadPhotoMetadatas() {}

    func deleteAllPhotos() {}
    func deleteAllScannedData() {}

    func updatePhotoMetadata(metadata: PhotoMetadata?, text: PhotoMetadataText?, note: PhotoMetadataNote?) {}

    func deletePhotoMetadata(metadata: PhotoMetadata) {}

    /// call this inside `updatePhotoMetadata`
    private func addPhotoMetadata(metadata: PhotoMetadata) {}

    static let sentenceHeight = CGFloat(0.01)
    static let sentenceGap = CGFloat(0.003)

    func getText(from identifier: String) -> PhotoMetadataText? {
        var sentences = [Sentence]()

        for index in 0 ..< 20 {
            let i = CGFloat(index)
            let sentence = Sentence(
                string: "Hello this is some testing text, AAAAAA",
                confidence: 0.8,
                topLeft: CGPoint(x: 0.1, y: (Self.sentenceGap + Self.sentenceHeight) * i),
                topRight: CGPoint(x: 0.8, y: (Self.sentenceGap + Self.sentenceHeight) * i),
                bottomRight: CGPoint(x: 0.8, y: (Self.sentenceGap + Self.sentenceHeight) * i + Self.sentenceHeight),
                bottomLeft: CGPoint(x: 0.1, y: (Self.sentenceGap + Self.sentenceHeight) * i + Self.sentenceHeight)
            )
            sentences.append(sentence)
        }
        let metadataText = PhotoMetadataText(
            sentences: sentences,
            scannedInLanguages: ["en_US"],
            scannedInVersion: "2.0.4"
        )

        return metadataText
    }

    func getNote(from identifier: String) -> PhotoMetadataNote? {
        return nil
    }
}
