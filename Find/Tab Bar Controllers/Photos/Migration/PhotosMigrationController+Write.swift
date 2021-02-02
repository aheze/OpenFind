//
//  PhotosMigrationController+Write.swift
//  Find
//
//  Created by Zheng on 1/2/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import SPAlert
import Photos
import SwiftEntryKit

extension PhotosMigrationController {
    
    func writeToPhotos(editablePhotos: [EditableHistoryModel], baseURL: URL) {
        self.isModalInPresentation = true
        cancelButton.isEnabled = false
        confirmButton.isEnabled = false
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.8, animations: {
                self.blurView.effect = UIBlurEffect(style: .regular)
                self.segmentIndicator.alpha = 1
                self.movingLabel.alpha = 1
                self.progressLabel.alpha = 1
            })
        }
        
        var editablePhotosWithErrors = [EditableHistoryModel]()
        var errorMessages = [String]()
        var finishedEditablePhotos = [EditableHistoryModel]()
        
        dispatchQueue.async {
            
            for editablePhoto in editablePhotos {
                var photoData: Data?
                
                do {
                    let data = try Data(contentsOf: baseURL.appendingPathComponent(editablePhoto.filePath))
                    photoData = data
                } catch {
                    editablePhotosWithErrors.append(editablePhoto)
                    let readableError = String(describing: error.localizedDescription)
                    errorMessages.append(readableError)
                }
                
                guard let data = photoData else {
                    self.dispatchSemaphore.signal() /// signal and animate number completed regardless
                    DispatchQueue.main.async {
                        self.savedAnotherImage()
                    }
                    continue
                }
                
                
                var photoIdentifier: String?
                PHPhotoLibrary.shared().performChanges({
                    
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    creationRequest.addResource(with: .photo, data: data, options: nil)
                    if let identifier = creationRequest.placeholderForCreatedAsset?.localIdentifier {
                        photoIdentifier = identifier
                    } else {
                    }
                }) { (success, error) in
                    
                    if
                        success,
                        let identifier = photoIdentifier
                    {
                        editablePhoto.assetIdentifier = identifier
                        finishedEditablePhotos.append(editablePhoto)
                    } else {
                        editablePhotosWithErrors.append(editablePhoto)
                        let readableError = String(describing: error?.localizedDescription)
                        errorMessages.append(readableError)
                    }
                    
                    self.dispatchSemaphore.signal() /// signal and animate number completed regardless
                    DispatchQueue.main.async {
                        self.savedAnotherImage()
                    }
                }
                
                self.dispatchSemaphore.wait()
            }
            
            DispatchQueue.main.async {
                self.finish(editablePhotosWithErrors: editablePhotosWithErrors, errorMessages: errorMessages, finishedEditablePhotos: finishedEditablePhotos)
            }
            
        }
    }
    
    func savedAnotherImage() {
        numberCompleted += 1
        let percentComplete = CGFloat(numberCompleted) / CGFloat(editablePhotosToMigrate.count)
        let percentCompleteOf100 = percentComplete * 100
        
        progressLabel.fadeTransition(0.1)
        progressLabel.text = "\(Int(percentCompleteOf100))%"
        
        segmentIndicator.updateProgress(percent: Degrees(percentCompleteOf100))
    }
    func finish(editablePhotosWithErrors: [EditableHistoryModel], errorMessages: [String], finishedEditablePhotos: [EditableHistoryModel]) {
        
        
        
        for templatePhoto in finishedEditablePhotos {
            for realPhoto in realPhotos {
                if realPhoto.dateCreated == templatePhoto.dateCreated {
                    
                    do {
                        try realm.write {
                            realPhoto.assetIdentifier = templatePhoto.assetIdentifier
                        }
                    } catch {
                        print("Error saving asset identifier or removing photo. \(error)")
                    }
                    let fullUrl = folderURL.appendingPathComponent(realPhoto.filePath)
                    deletePhotoAtPath(fullUrl: fullUrl)
                }
            }
        }
        
        if !editablePhotosWithErrors.isEmpty {
            resetProgress()
            tryAgain = true
            
            let tryAgain = NSLocalizedString("PhotosMigrationVC+tryAgain", comment: "")
            confirmButton.setTitle(tryAgain, for: .normal)
            
            let couldNotBeAutoMoved = NSLocalizedString("couldNotBeAutoMoved", comment: "")
            promptLabel.text = couldNotBeAutoMoved
            tapTryAgainView.alpha = 1
            tapTryAgainHeightC.constant = 40
            
            var errorToShow = "Errors:\n"
            for (index, message) in errorMessages.enumerated() {
                if index == errorMessages.count - 1 {
                    errorToShow = errorToShow + message
                } else {
                    errorToShow = errorToShow + message + "\n"
                }
            }
            
            
            let somePhotosCouldNotBeMoved = NSLocalizedString("somePhotosCouldNotBeMoved", comment: "")
            let okText = NSLocalizedString("okText", comment: "")
            
            let alert = UIAlertController(title: somePhotosCouldNotBeMoved, message: errorToShow, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: okText, style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            editablePhotosToMigrate = editablePhotosWithErrors
            collectionView.reloadData()
        } else {
            let finishedMoving = NSLocalizedString("finishedMoving", comment: "")
            let yourPhotosHaveBeenMoved = NSLocalizedString("yourPhotosHaveBeenMoved", comment: "")
            
            let finishedMovingMessage = finishedMoving
            let detailsMessage = yourPhotosHaveBeenMoved
            let alertView = SPAlertView(title: finishedMovingMessage, message: detailsMessage, preset: SPAlertPreset.done)
            alertView.duration = 2.6
            alertView.present()
            resetProgress()
            self.dismiss(animated: true, completion: nil)
            completed?()
        }
    }
    
    /// start ui from scratch
    func resetProgress() {
        confirmButton.isEnabled = true
        cancelButton.isEnabled = true
        UIView.animate(withDuration: 0.8, animations: {
            self.blurView.effect = nil
            self.segmentIndicator.alpha = 0
            self.movingLabel.alpha = 0
            self.progressLabel.alpha = 0
        }) { _ in
            self.progressLabel.text = "0%"
            self.numberCompleted = 0
            self.segmentIndicator.updateProgress(percent: Degrees(0))
        }
    }
    func manualMove() {
        var objects = [HistorySharing]()
        for photo in editablePhotosToMigrate {
            let shareObject = HistorySharing(filePath: photo.filePath, folderURL: folderURL)
            objects.append(shareObject)
        }
        
        let activityViewController = UIActivityViewController(activityItems: objects, applicationActivities: nil)
        
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceRect = confirmButton.bounds
            popoverController.sourceView = confirmButton
        }
        activityViewController.completionWithItemsHandler = { (_, completed, _, hasError) in
            
            var attributes = EKAttributes.topFloat
            attributes.displayDuration = .infinity
            attributes.entryInteraction = .absorbTouches
            attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .easeOut)
            attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
            attributes.screenBackground = .color(color: EKColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3802521008)))
            attributes.screenInteraction = .absorbTouches
            
            let finishedMovingQuestion = NSLocalizedString("finishedMovingQuestion", comment: "")
            let ifYouHaveFinishedMovingPhotos = NSLocalizedString("ifYouHaveFinishedMovingPhotos", comment: "")
            let noText = NSLocalizedString("noText", comment: "")
            let imFinished = NSLocalizedString("imFinished", comment: "")
            
            let titleMessage = finishedMovingQuestion
            let description = ifYouHaveFinishedMovingPhotos
            let leftButtonTitle = noText
            let rightButtonTitle = imFinished
            
            self.showManualConfirmation(attributes: attributes, titleMessage: titleMessage, desc: description, leftButton: leftButtonTitle, yesButton: rightButtonTitle)
            
        }
        self.present(activityViewController, animated: true)
    }
    
    func showManualConfirmation(attributes: EKAttributes, titleMessage: String, desc: String, leftButton: String, yesButton: String, image: String = "WhiteCheckmark") {
        let displayMode = EKAttributes.DisplayMode.inferred
        
        let title = EKProperty.LabelContent(text: titleMessage, style: .init(font: UIFont.systemFont(ofSize: 20, weight: .bold), color: .white, displayMode: displayMode))
        let description = EKProperty.LabelContent(text: desc, style: .init(font: UIFont.systemFont(ofSize: 14, weight: .regular), color: .white,displayMode: displayMode))
        let image = EKProperty.ImageContent( imageName: image, displayMode: displayMode, size: CGSize(width: 35, height: 35), contentMode: .scaleAspectFit)
        let simpleMessage = EKSimpleMessage(image: image, title: title, description: description)
        let buttonFont = UIFont.systemFont(ofSize: 20, weight: .bold)
        let okButtonLabelStyle = EKProperty.LabelStyle( font: UIFont.systemFont(ofSize: 20, weight: .bold), color: .white, displayMode: displayMode)
        let okButtonLabel = EKProperty.LabelContent( text: yesButton, style: okButtonLabelStyle)
        let closeButtonLabelStyle = EKProperty.LabelStyle(font: buttonFont, color: EKColor(#colorLiteral(red: 1, green: 0.9675828359, blue: 0.9005832124, alpha: 1)), displayMode: displayMode)
        let closeButtonLabel = EKProperty.LabelContent(text: leftButton, style: closeButtonLabelStyle)
        
            let okButton = EKProperty.ButtonContent(
                label: okButtonLabel,
                backgroundColor: .clear,
                highlightedBackgroundColor: SEKColor.Gray.a800.with(alpha: 0.05)
            ) { [weak self] in
                self?.deleteErrorPhotos()
                self?.completed?()
                self?.dismiss(animated: true, completion: nil)
                SwiftEntryKit.dismiss()
            }
            let closeButton = EKProperty.ButtonContent(
                label: closeButtonLabel,
                backgroundColor: .clear,
                highlightedBackgroundColor: SEKColor.Gray.a800.with(alpha: 0.05),
                displayMode: displayMode
            ) { 
                SwiftEntryKit.dismiss()
            }
            let buttonsBarContent = EKProperty.ButtonBarContent(with: closeButton, okButton, separatorColor: SEKColor.Gray.light, buttonHeight: 60, displayMode: displayMode, expandAnimatedly: true )
            let alertMessage = EKAlertMessage(simpleMessage: simpleMessage, imagePosition: .left, buttonBarContent: buttonsBarContent
            )
            let contentView = EKAlertMessageView(with: alertMessage)
            contentView.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            contentView.layer.cornerRadius = 10
            SwiftEntryKit.display(entry: contentView, using: attributes)
    }
    
    func deleteErrorPhotos() {
        for templatePhoto in editablePhotosToMigrate {
            for realPhoto in realPhotos {
                if realPhoto.dateCreated == templatePhoto.dateCreated {
                    do {
                        try realm.write {
                            realm.delete(realPhoto.contents)
                            realm.delete(realPhoto)
                        }
                    } catch {
                        print("Error saving asset identifier or removing photo. \(error)")
                    }
                    let fullUrl = folderURL.appendingPathComponent(realPhoto.filePath)
                    deletePhotoAtPath(fullUrl: fullUrl)
                }
            }
        }
    }
    func deletePhotoAtPath(fullUrl: URL) {
        if FileManager.default.fileExists(atPath: fullUrl.path) {
            do {
                try FileManager.default.removeItem(at: fullUrl)
            } catch {
                print("error deleting file. \(error)")
            }
        }
    }
}

