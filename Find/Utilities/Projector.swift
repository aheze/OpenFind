////
////  ProjectorFiles.swift
////  Projector
////
////  Created by Zheng on 6/5/20.
////  Copyright © 2020 Zheng. All rights reserved.
////
//
//import UIKit
//import MediaPlayer
//
//
//class ProjectorCollectionViewController: UIViewController {
//    
//    weak var collectionView: UICollectionView!
//    weak var selectedIconView: UIView!
//    weak var collectionViewReferenceView: UIView!
//    
//    weak var controlsView: UIView!
//    
//    weak var copyCodeView: UIView!
//    weak var copyButton: UIButton!
//    
//    var rectStringForCopying = ""
//    
//    weak var leftButton: UIButton!
//    weak var middleButton: UIButton!
//    weak var rightButton: UIButton!
//    
//    weak var menuButton: UIButton!
//    var isShowingMenu = true
//    var enablePressMenu = true
//    
//    var leftConstraint = NSLayoutConstraint()
//    var bottomContraint = NSLayoutConstraint()
//    
//    var leftMidConstraint = NSLayoutConstraint()
//    var bottomMidConstraint = NSLayoutConstraint()
//    
//    var widthConstraint = NSLayoutConstraint()
//    var heightConstraint = NSLayoutConstraint()
//    
//    var originalSize = CGSize()
//    var originalWidth = CGFloat()
//    var originalHeight = CGFloat()
//    
//    
//    var currentVolume = Float(0)
//    var outputVolumeObserve: NSKeyValueObservation?
//    let audioSession = AVAudioSession.sharedInstance()
//    
//    
//    @objc func volumeChanged(notification: NSNotification) {
//        if let userInfo = notification.userInfo {
//            if let volumeChangeType = userInfo ["AVSystemController_AudioVolumeChangeReasonNotificationParameter"] as? String {
//                if volumeChangeType == "ExplicitVolumeChange" {
//                    if let volume = notification.userInfo?["AVSystemController_AudioVolumeNotificationParameter"] as? Float {
//                        
//                        func up() {
//                            if ProjectorConfiguration.currentIndex != ProjectorConfiguration.devices.count - 1 {
//                                selectCellAt(IndexPath(item: ProjectorConfiguration.currentIndex + 1, section: 0))
//                            }
//                        }
//                        
//                        func down() {
//                            if ProjectorConfiguration.currentIndex != 0 {
//                                selectCellAt(IndexPath(item: ProjectorConfiguration.currentIndex - 1, section: 0))
//                            }
//                        }
//                        
//                        
//                        if volume > currentVolume {
//                            print("up")
//                            up()
//                        } else if volume < currentVolume {
//                            print("down")
//                            down()
//                        } else {
//                            print("max or min...")
//                            if volume == Float(1) {
//                                print("up")
//                                up()
//                            } else {
//                                print("down")
//                                down()
//                            }
//                        }
//                        currentVolume = volume
//                    }
//                }
//            }
//        }
//    }
//    
//    
//    func disableMenuPress() {
//        updateCopyboardString()
//        enablePressMenu = false
//        disableMenu()
//    }
//    
//    func enableMenuPress() {
//        updateCopyboardString()
//        enablePressMenu = true
//        enableMenu()
//    }
//    func updateCopyboardString() {
//        
//        let projectRect = ProjectorConfiguration.rootWindow.frame
//        let xValue = projectRect.origin.x
//        let yValue = projectRect.origin.y
//        let wValue = projectRect.size.width
//        let hValue = projectRect.size.height
//        
//        let roundedXValue = round(1000 * xValue)/1000
//        let roundedYValue = round(1000 * yValue)/1000
//        let roundedWValue = round(1000 * wValue)/1000
//        let roundedHValue = round(1000 * hValue)/1000
//        
//        rectStringForCopying = "\(roundedXValue)=\(roundedYValue)=\(roundedWValue)=\(roundedHValue)=\(ProjectorConfiguration.statusBarHeight)"
//    }
//    
//    func disableMenu() {
//        isShowingMenu = false
//        
//        UIView.animate(withDuration: 0.3, animations: {
//            self.controlsView.frame = CGRect(x: 40, y: 0, width: 40, height: 40)
//            
//            self.leftButton.alpha = 0
//            self.middleButton.alpha = 0
//            self.rightButton.alpha = 0
//            
//            self.collectionView.alpha = 0
//            self.selectedIconView.alpha = 0
//        })
//        
//        guard #available(iOS 13, *) else {
//            print("You're not running iOS 13, so some icons may not show up.")
//            return
//        }
//        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 40, weight: .semibold)
//        let menuImage = UIImage(systemName: "slider.horizontal.3", withConfiguration: symbolConfiguration)?.withTintColor(UIColor.white, renderingMode: .alwaysOriginal)
//        self.menuButton.setImage(menuImage, for: .normal)
//        
//        
//    }
//    func enableMenu() {
//        isShowingMenu = true
//        
//        UIView.animate(withDuration: 0.3, animations: {
//            self.controlsView.frame = CGRect(x: 40, y: 0, width: 150, height: 40)
//            
//            self.collectionView.alpha = 1
//            self.selectedIconView.alpha = 1
//            self.leftButton.alpha = 0.4
//            self.middleButton.alpha = 0.4
//            self.rightButton.alpha = 0.4
//            
//            switch ProjectorConfiguration.settings.position {
//            case .centered:
//                self.middleButton.alpha = 1
//            case .left:
//                self.leftButton.alpha = 1
//            case .right:
//                self.rightButton.alpha = 1
//            case .top:
//                self.leftButton.alpha = 1
//            case .bottom:
//                self.rightButton.alpha = 1
//            }
//        })
//        
//        guard #available(iOS 13, *) else {
//            print("You're not running iOS 13, so some icons may not show up.")
//            return
//        }
//        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 30, weight: .semibold)
//        let menuImage = UIImage(systemName: "xmark", withConfiguration: symbolConfiguration)?.withTintColor(UIColor.white, renderingMode: .alwaysOriginal)
//        self.menuButton.setImage(menuImage, for: .normal)
//        
//        //        self.collectionView.isHidden = false
//        
//    }
//    
//    @objc func copyPressed(sender: UIButton!) {
//        let pasteboard = UIPasteboard.general
//        pasteboard.string = rectStringForCopying
//        //        print("copyboard: \(rectStringForCopying)")
//        UIView.animate(withDuration: 0.2, animations: {
//            self.copyCodeView.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
//        }) { _ in
//            UIView.animate(withDuration: 0.2, delay: 0.5, options: .curveLinear, animations: {
//                self.copyCodeView.backgroundColor = #colorLiteral(red: 0.3232996324, green: 0.3232996324, blue: 0.3232996324, alpha: 1)
//            }, completion: nil)
//        }
//        
//    }
//    @objc func menuPressed(sender: UIButton!) {
//        if enablePressMenu {
//            if isShowingMenu {
//                disableMenu()
//            } else {
//                enableMenu()
//            }
//        } else {
//            let alert = UIAlertController(title: "Rotate your device!", message: "Changing the Projector configuration is only allowed in portrait view", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default))
//            self.present(alert, animated: true, completion: nil)
//        }
//    }
//    
//    
//    @objc func leftPressed(sender: UIButton!) {
//        
//        let currentSize = ProjectorConfiguration.simulatedDevice.getSize()
//        let currentAspectRatio = currentSize.width / currentSize.height
//        let originalAspectRatio = originalWidth / originalHeight
//        
//        if originalAspectRatio < currentAspectRatio {
//            ProjectorConfiguration.settings.position = .top
//        } else if originalAspectRatio > currentAspectRatio {
//            ProjectorConfiguration.settings.position = .left
//        }
//        
//        leftButton.alpha = 1
//        middleButton.alpha = 0.6
//        rightButton.alpha = 0.6
//        animateCollectionviewChange(newDevice: ProjectorConfiguration.simulatedDevice)
//    }
//    @objc func centerPressed(sender: UIButton!) {
//        ProjectorConfiguration.settings.position = .centered
//        leftButton.alpha = 0.6
//        middleButton.alpha = 1
//        rightButton.alpha = 0.6
//        animateCollectionviewChange(newDevice: ProjectorConfiguration.simulatedDevice)
//    }
//    @objc func rightPressed(sender: UIButton!) {
//        let currentSize = ProjectorConfiguration.simulatedDevice.getSize()
//        let currentAspectRatio = currentSize.width / currentSize.height
//        let originalAspectRatio = originalWidth / originalHeight
//        
//        if originalAspectRatio < currentAspectRatio {
//            ProjectorConfiguration.settings.position = .bottom
//        } else if originalAspectRatio > currentAspectRatio {
//            ProjectorConfiguration.settings.position = .right
//        }
//        
//        leftButton.alpha = 0.6
//        middleButton.alpha = 0.6
//        rightButton.alpha = 1
//        animateCollectionviewChange(newDevice: ProjectorConfiguration.simulatedDevice)
//    }
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view = PassView()
//        
//        let originalVol = AVAudioSession.sharedInstance().outputVolume
//        ProjectorConfiguration.originalVolume = originalVol
//        currentVolume = originalVol
//        
//        let volumeView = MPVolumeView(frame: CGRect (origin: CGPoint (x:-500, y: -500), size: CGSize.zero))
//        self.view.addSubview(volumeView)
//        NotificationCenter.default.addObserver(self, selector: #selector(volumeChanged(notification:)), name:
//            NSNotification.Name("AVSystemController_SystemVolumeDidChangeNotification"), object: nil)
//        
//        
//        ProjectorConfiguration.collectionController = self
//        
//        setUpViews()
//        
//        if let indexItem = ProjectorConfiguration.devices.firstIndex(of: ProjectorConfiguration.simulatedDevice) {
//            let indP = IndexPath(item: indexItem, section: 0)
//            collectionView.layoutIfNeeded()
//            collectionView.scrollToItem(at: indP, at: .centeredHorizontally, animated: false)
//        }
//        
//        
//        
//    }
//    
//}
//
//
//extension ProjectorCollectionViewController: UICollectionViewDataSource {
//    
//    func collectionView(_ collectionView: UICollectionView,
//                        numberOfItemsInSection section: Int) -> Int {
//        return ProjectorConfiguration.devices.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView,
//                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.identifier, for: indexPath) as! Cell
//        let device = ProjectorConfiguration.devices[indexPath.item]
//        cell.textLabel.text = device.getName()
//        return cell
//    }
//}
//extension ProjectorCollectionViewController: UICollectionViewDelegate {
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        var nearestIndexPath = IndexPath(item: 0, section: 0)
//        var nearestDistance = CGFloat(9999)
//        let centerPoint = CGPoint(x: collectionView.bounds.width / 2, y: 20)
//        let indexPaths = collectionView.indexPathsForVisibleItems
//        for indexPath in indexPaths {
//            if let attributes = collectionView.layoutAttributesForItem(at: indexPath) {
//                let center = attributes.center
//                let actual = collectionView.convert(center, to: collectionViewReferenceView)
//                let dist = distance(actual, centerPoint)
//                if dist <= nearestDistance {
//                    nearestDistance = dist
//                    nearestIndexPath = indexPath
//                }
//            }
//        }
//        selectCellAt(nearestIndexPath)
//    }
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        if (!decelerate) {
//            var nearestIndexPath = IndexPath(item: 0, section: 0)
//            var nearestDistance = CGFloat(9999)
//            let centerPoint = CGPoint(x: collectionView.bounds.width / 2, y: 20)
//            let indexPaths = collectionView.indexPathsForVisibleItems
//            for indexPath in indexPaths {
//                if let attributes = collectionView.layoutAttributesForItem(at: indexPath) {
//                    let center = attributes.center
//                    let actual = collectionView.convert(center, to: collectionViewReferenceView)
//                    let dist = distance(actual, centerPoint)
//                    if dist <= nearestDistance {
//                        nearestDistance = dist
//                        nearestIndexPath = indexPath
//                    }
//                }
//            }
//            
//            selectCellAt(nearestIndexPath)
//        }
//    }
//    
//    func selectCellAt(_ indexPath: IndexPath) {
//        
//        let newDevice = ProjectorConfiguration.devices[indexPath.item]
//        
//        animateCollectionviewChange(newDevice: newDevice)
//        
//        ProjectorConfiguration.currentIndex = indexPath.item
//        
//        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
//        
//    }
//    func animateCollectionviewChange(newDevice: DeviceType) {
//        
//        
//        let currentSimulatedDevice = ProjectorConfiguration.simulatedDevice
//        let currentSimulatedSize = currentSimulatedDevice.getSize()
//        let currentAspectRatio = currentSimulatedSize.width / currentSimulatedSize.height
//        let deviceName = newDevice.getName()
//        let nameWidth = width(text: deviceName, height: 40)
//        let halfNameWidth = nameWidth / 2
//        
//        let originalAspectRatio = originalWidth / originalHeight
//        
//        let newSize = newDevice.getSize()
//        let newAspectRatio = newSize.width / newSize.height
//        
//        
//        var isSideways = true
//        var originallyWasSideways = false
//        
//        if originalAspectRatio < currentAspectRatio {
//            originallyWasSideways = false
//        } else if originalAspectRatio > currentAspectRatio {
//            originallyWasSideways = true
//        }
//        
//        
//        if originalAspectRatio < newAspectRatio {
//            isSideways = false
//        } else if originalAspectRatio > newAspectRatio {
//            isSideways = true
//        }
//        
//        let originalPosition = ProjectorConfiguration.settings.position
//        
//        
//        if originallyWasSideways != isSideways {
//            leftButton.alpha = 0.6
//            middleButton.alpha = 0.6
//            rightButton.alpha = 0.6
//            
//            switch originalPosition {
//                
//            case .centered:
//                middleButton.alpha = 1
//                ProjectorConfiguration.settings.position = .centered
//            case .left:
//                leftButton.alpha = 1
//                ProjectorConfiguration.settings.position = .top
//            case .right:
//                rightButton.alpha = 1
//                ProjectorConfiguration.settings.position = .bottom
//            case .top:
//                leftButton.alpha = 1
//                ProjectorConfiguration.settings.position = .left
//            case .bottom:
//                rightButton.alpha = 1
//                ProjectorConfiguration.settings.position = .right
//            }
//        }
//        var collectionTransform = CGAffineTransform()
//        var horizontalOffset = CGFloat(0)
//        var verticalOffset = CGFloat(0)
//        switch ProjectorConfiguration.settings.position {
//        case .centered:
//            if originalAspectRatio < newAspectRatio {
//                collectionTransform = CGAffineTransform(rotationAngle: CGFloat(0))
//            } else if originalAspectRatio > newAspectRatio {
//                collectionTransform = CGAffineTransform(rotationAngle: CGFloat(-90).degreesToRadians)
//            }
//            
//        case .left:
//            isSideways = true
//            collectionTransform = CGAffineTransform(rotationAngle: CGFloat(-90).degreesToRadians)
//            horizontalOffset = originalWidth - 40
//        case .right:
//            isSideways = true
//            collectionTransform = CGAffineTransform(rotationAngle: CGFloat(-90).degreesToRadians)
//            
//        case .top:
//            isSideways = false
//            collectionTransform = CGAffineTransform(rotationAngle: CGFloat(0))
//        case .bottom:
//            isSideways = false
//            verticalOffset = -(originalHeight - 40)
//            collectionTransform = CGAffineTransform(rotationAngle: CGFloat(0))
//        }
//        
//        var statusOffset = CGFloat(0)
//        if ProjectorConfiguration.settings.shouldStopAtStatusBar {
//            statusOffset = ProjectorConfiguration.statusBarHeight
//        }
//        
//        var anchorPoint = CGPoint()
//        
//        var newFrameRect = CGRect()
//        
//        if isSideways {
//            leftMidConstraint.constant = horizontalOffset
//            bottomMidConstraint.constant = verticalOffset
//            widthConstraint.constant = originalHeight
//            heightConstraint.constant = 40
//            
//            leftMidConstraint.isActive = true
//            bottomMidConstraint.isActive = true
//            leftConstraint.isActive = false
//            bottomContraint.isActive = false
//            newFrameRect = CGRect(x: (originalHeight / 2) - halfNameWidth - 8, y: 0, width: nameWidth + 16, height: 40)
//            
//            collectionView.contentInset = UIEdgeInsets(top: 0, left: (originalHeight / 2), bottom: 0, right: (originalHeight / 2))
//            anchorPoint = CGPoint(x: 0, y: 0)
//        } else {
//            selectedIconView.frame = CGRect(x: statusOffset + (originalWidth / 2) - halfNameWidth - 8, y: UIScreen.main.bounds.size.height - verticalOffset, width: nameWidth + 16, height: 40)
//            leftConstraint.constant = horizontalOffset
//            bottomContraint.constant = verticalOffset
//            widthConstraint.constant = originalWidth
//            heightConstraint.constant = 40
//            
//            
//            leftMidConstraint.isActive = false
//            bottomMidConstraint.isActive = false
//            leftConstraint.isActive = true
//            bottomContraint.isActive = true
//            
//            newFrameRect = CGRect(x: (originalWidth / 2) - halfNameWidth - 8, y: 0, width: nameWidth + 16, height: 40)
//            
//            collectionView.contentInset = UIEdgeInsets(top: 0, left: (originalWidth / 2), bottom: 0, right: (originalWidth / 2))
//            anchorPoint = CGPoint(x: 0.5, y: 0.5)
//        }
//        UIView.animate(withDuration: 0.5, animations: {
//            self.collectionViewReferenceView.layoutIfNeeded()
//            self.collectionViewReferenceView.setAnchorPoint(anchorPoint)
//            self.collectionViewReferenceView.transform = collectionTransform
//            self.selectedIconView.frame = newFrameRect
//        })
//        
//        ProjectorConfiguration.simulatedDevice = newDevice
//        //        let rectangle = Projector.project(device: newDevice)
//        
//        Projector.project(device: newDevice) { rect in
//            //            self.projectedRect = rect
//            self.updateCopyboardString()
//        }
//        //        self.projectedRect = rectangle
//        
//        
//    }
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        selectCellAt(indexPath)
//    }
//}
//
//extension ProjectorCollectionViewController: UICollectionViewDelegateFlowLayout {
//    
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//        var properWidth = CGFloat(50)
//        let device = ProjectorConfiguration.devices[indexPath.item]
//        let deviceName = device.getName()
//        properWidth = width(text: deviceName, height: 40)
//        
//        return CGSize(width: properWidth + 20, height: 40)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) //.zero
//    }
//    
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 0
//    }
//    
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 0
//    }
//}
//
//extension ProjectorCollectionViewController {
//    func setUpViews() {
//        
//        updateCopyboardString()
//        
//        
//        let iconView = UIView()
//        
//        let referenceView = UIView(frame: .zero)
//        referenceView.backgroundColor = UIColor.clear
//        referenceView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(referenceView)
//        
//        iconView.backgroundColor = UIColor.gray
//        iconView.layer.cornerRadius = 10
//        referenceView.addSubview(iconView)
//        self.selectedIconView = iconView
//        
//        self.selectedIconView.alpha = 0
//        
//        var collectionTransform = CGAffineTransform()
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        collectionView.showsHorizontalScrollIndicator = false
//        referenceView.addSubview(collectionView)
//        self.collectionView = collectionView
//        self.collectionViewReferenceView = referenceView
//        
//        self.collectionView.alpha = 0
//        
//        let overlayControls = UIView()
//        overlayControls.frame = CGRect(x: 40, y: 0, width: 40, height: 40)
//        overlayControls.layer.cornerRadius = 6
//        overlayControls.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
//        overlayControls.backgroundColor = #colorLiteral(red: 0.4158049939, green: 0.4158049939, blue: 0.4158049939, alpha: 1)
//        referenceView.addSubview(overlayControls)
//        self.controlsView = overlayControls
//        
//        
//        
//        
//        
//        let menu = UIButton()
//        overlayControls.addSubview(menu)
//        menu.frame = CGRect(x: 0, y: 2, width: 36, height: 36)
//        menu.imageView?.contentMode = .scaleAspectFit
//        menu.addTarget(self, action: #selector(menuPressed), for: .touchUpInside)
//        self.menuButton = menu
//        
//        let leftButton = UIButton()
//        overlayControls.addSubview(leftButton)
//        leftButton.frame = CGRect(x: 48, y: 2, width: 36, height: 36)
//        leftButton.imageView?.contentMode = .scaleAspectFit
//        leftButton.addTarget(self, action: #selector(leftPressed), for: .touchUpInside)
//        self.leftButton = leftButton
//        
//        
//        let middleButton = UIButton()
//        overlayControls.addSubview(middleButton)
//        middleButton.frame = CGRect(x: 87, y: 10, width: 20, height: 20)
//        middleButton.imageView?.contentMode = .scaleAspectFit
//        middleButton.addTarget(self, action: #selector(centerPressed), for: .touchUpInside)
//        self.middleButton = middleButton
//        
//        
//        let rightButton = UIButton()
//        overlayControls.addSubview(rightButton)
//        rightButton.frame = CGRect(x: 108, y: 2, width: 36, height: 36)
//        rightButton.imageView?.contentMode = .scaleAspectFit
//        rightButton.addTarget(self, action: #selector(rightPressed), for: .touchUpInside)
//        self.rightButton = rightButton
//        
//        
//        let codeOverlayView = UIView()
//        codeOverlayView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
//        codeOverlayView.backgroundColor = #colorLiteral(red: 0.3232996324, green: 0.3232996324, blue: 0.3232996324, alpha: 1)
//        self.copyCodeView = codeOverlayView
//        referenceView.addSubview(codeOverlayView)
//        
//        let copyButton =  UIButton()
//        copyButton.frame = CGRect(x: 2, y: 2, width: 36, height: 36)
//        codeOverlayView.addSubview(copyButton)
//        copyButton.addTarget(self, action: #selector(copyPressed), for: .touchUpInside)
//        self.copyButton = copyButton
//        
//        
//        if #available(iOS 13.0, *) {
//            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 40, weight: .semibold)
//            
//            let menuImage = UIImage(systemName: "slider.horizontal.3", withConfiguration: symbolConfiguration)?.withTintColor(UIColor.white, renderingMode: .alwaysOriginal)
//            menu.setImage(menuImage, for: .normal)
//            
//            let leftImage = UIImage(systemName: "chevron.up", withConfiguration: symbolConfiguration)?.withTintColor(UIColor.white, renderingMode: .alwaysOriginal)
//            leftButton.setImage(leftImage, for: .normal)
//            
//            let middleImage = UIImage(systemName: "circle.fill", withConfiguration: symbolConfiguration)?.withTintColor(UIColor.white, renderingMode: .alwaysOriginal)
//            middleButton.setImage(middleImage, for: .normal)
//            
//            
//            let rightImage = UIImage(systemName: "chevron.down", withConfiguration: symbolConfiguration)?.withTintColor(UIColor.white, renderingMode: .alwaysOriginal)
//            rightButton.setImage(rightImage, for: .normal)
//            
//            let copyConfiguration = UIImage.SymbolConfiguration(pointSize: 30, weight: .semibold)
//            let copyImage = UIImage(systemName: "doc.on.clipboard", withConfiguration: copyConfiguration)?.withTintColor(UIColor.white, renderingMode: .alwaysOriginal)
//            copyButton.setImage(copyImage, for: .normal)
//            
//            
//        }
//        
//        
//        leftButton.alpha = 0
//        middleButton.alpha = 0
//        rightButton.alpha = 0
//        
//        
//        
//        // MARK: Collection View setup
//        originalSize = ProjectorConfiguration.originalSize
//        originalWidth = originalSize.width
//        originalHeight = originalSize.height
//        
//        let originalAspectRatio = originalWidth / originalHeight
//        
//        let newSize = ProjectorConfiguration.simulatedDevice.getSize()
//        let newAspectRatio = newSize.width / newSize.height
//        
//        var horizontalOffset = CGFloat(0)
//        var verticalOffset = CGFloat(0)
//        
//        var isSideways = true
//        
//        switch ProjectorConfiguration.settings.position {
//        case .centered:
//            if originalAspectRatio < newAspectRatio {
//                collectionTransform = CGAffineTransform(rotationAngle: CGFloat(0))
//                isSideways = false
//            } else if originalAspectRatio > newAspectRatio {
//                isSideways = true
//                collectionTransform = CGAffineTransform(rotationAngle: CGFloat(-90).degreesToRadians)
//            }
//            
//        case .left:
//            isSideways = true
//            collectionTransform = CGAffineTransform(rotationAngle: CGFloat(-90).degreesToRadians)
//            horizontalOffset = originalWidth - 40
//        case .right:
//            isSideways = true
//            collectionTransform = CGAffineTransform(rotationAngle: CGFloat(-90).degreesToRadians)
//        case .top:
//            isSideways = false
//            collectionTransform = CGAffineTransform(rotationAngle: CGFloat(0))
//        case .bottom:
//            isSideways = false
//            verticalOffset = -(originalHeight - 40)
//            collectionTransform = CGAffineTransform(rotationAngle: CGFloat(0))
//        }
//        
//        let deviceName = ProjectorConfiguration.simulatedDevice.getName()
//        
//        let nameWidth = width(text: deviceName, height: 40)
//        let halfNameWidth = nameWidth / 2
//        
//        var statusOffset = CGFloat(0)
//        if ProjectorConfiguration.settings.shouldStopAtStatusBar {
//            statusOffset = ProjectorConfiguration.statusBarHeight
//        }
//        
//        if isSideways {
//            iconView.frame = CGRect(x: (originalHeight / 2) - halfNameWidth - 8, y: 0, width: nameWidth + 16, height: 40)
//            
//            leftMidConstraint = referenceView.centerXAnchor.constraint(equalTo: self.view.leadingAnchor, constant: horizontalOffset)
//            bottomMidConstraint = referenceView.centerYAnchor.constraint(equalTo: self.view.bottomAnchor, constant: verticalOffset)
//            widthConstraint = referenceView.widthAnchor.constraint(equalToConstant: originalHeight)
//            heightConstraint = referenceView.heightAnchor.constraint(equalToConstant: 40)
//            
//            leftConstraint = collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: horizontalOffset)
//            bottomContraint = collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: verticalOffset)
//            
//            leftMidConstraint.isActive = true
//            bottomMidConstraint.isActive = true
//            leftConstraint.isActive = false
//            bottomContraint.isActive = false
//            widthConstraint.isActive = true
//            heightConstraint.isActive = true
//            
//            collectionView.contentInset = UIEdgeInsets(top: 0, left: (originalHeight / 2), bottom: 0, right: (originalHeight / 2))
//            referenceView.setAnchorPoint(CGPoint(x: 0, y: 0))
//            referenceView.transform = collectionTransform
//        } else {
//            selectedIconView.frame = CGRect(x: statusOffset + (originalWidth / 2) - halfNameWidth - 8, y: UIScreen.main.bounds.size.height - verticalOffset, width: nameWidth + 16, height: 40)
//            leftConstraint = collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: horizontalOffset)
//            bottomContraint = collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: verticalOffset)
//            
//            widthConstraint = collectionView.widthAnchor.constraint(equalToConstant: originalWidth)
//            heightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 40)
//            
//            leftMidConstraint = referenceView.centerXAnchor.constraint(equalTo: self.view.leadingAnchor, constant: horizontalOffset)
//            bottomMidConstraint = referenceView.centerYAnchor.constraint(equalTo: self.view.bottomAnchor, constant: verticalOffset)
//            
//            collectionView.contentInset = UIEdgeInsets(top: 0, left: (originalWidth / 2), bottom: 0, right: (originalWidth / 2))
//            referenceView.setAnchorPoint(CGPoint(x: 0.5, y: 0.5))
//            referenceView.transform = collectionTransform
//            
//            leftMidConstraint.isActive = false
//            bottomMidConstraint.isActive = false
//            leftConstraint.isActive = true
//            bottomContraint.isActive = true
//            widthConstraint.isActive = true
//            heightConstraint.isActive = true
//        }
//        
//        NSLayoutConstraint.activate([
//            referenceView.topAnchor.constraint(equalTo: collectionView.topAnchor),
//            referenceView.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor),
//            referenceView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
//            referenceView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
//        ])
//        
//        self.collectionView.dataSource = self
//        self.collectionView.delegate = self
//        self.collectionView.register(Cell.self, forCellWithReuseIdentifier: Cell.identifier)
//        self.collectionView.backgroundColor = .white
//        
//        self.collectionView.backgroundColor = UIColor.clear
//        ProjectorConfiguration.initializedCollectionController = true
//    }
//}
//
//extension ProjectorCollectionViewController {
//    func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
//        let xDist = a.x - b.x
//        let yDist = a.y - b.y
//        return CGFloat(sqrt(xDist * xDist + yDist * yDist))
//    }
//    func width(text: String, height: CGFloat) -> CGFloat {
//        let attributes: [NSAttributedString.Key: Any] = [
//            .font: UIFont.systemFont(ofSize: 17)
//        ]
//        let attributedText = NSAttributedString(string: text, attributes: attributes)
//        let constraintBox = CGSize(width: .greatestFiniteMagnitude, height: height)
//        let textWidth = attributedText.boundingRect(with: constraintBox, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).width.rounded(.up)
//        
//        return textWidth
//    }
//}
//
//
//extension UIWindow {
//    /// Helper to get pre transform frame
//    var originalFrame: CGRect {
//        let currentTransform = transform
//        transform = .identity
//        let originalFrame = frame
//        transform = currentTransform
//        return originalFrame
//    }
//    
//    /// Helper to get point offset from center
//    func centerOffset(_ point: CGPoint) -> CGPoint {
//        return CGPoint(x: point.x - center.x, y: point.y - center.y)
//    }
//    
//    /// Helper to get point back relative to center
//    func pointRelativeToCenter(_ point: CGPoint) -> CGPoint {
//        return CGPoint(x: point.x + center.x, y: point.y + center.y)
//    }
//    
//    /// Helper to get point relative to transformed coords
//    func newPointInView(_ point: CGPoint) -> CGPoint {
//        // get offset from center
//        let offset = centerOffset(point)
//        // get transformed point
//        let transformedPoint = offset.applying(transform)
//        // make relative to center
//        return pointRelativeToCenter(transformedPoint)
//    }
//    
//    var newTopLeft: CGPoint {
//        return newPointInView(originalFrame.origin)
//    }
//    
//    var newTopRight: CGPoint {
//        var point = originalFrame.origin
//        point.x += originalFrame.width
//        return newPointInView(point)
//    }
//    
//    var newBottomLeft: CGPoint {
//        var point = originalFrame.origin
//        point.y += originalFrame.height
//        return newPointInView(point)
//    }
//    
//    var newBottomRight: CGPoint {
//        var point = originalFrame.origin
//        point.x += originalFrame.width
//        point.y += originalFrame.height
//        return newPointInView(point)
//    }
//}
//
//
//class Cell: UICollectionViewCell {
//    
//    static var identifier: String = "Cell"
//    
//    weak var textLabel: UILabel!
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        let textLabel = UILabel(frame: .zero)
//        textLabel.translatesAutoresizingMaskIntoConstraints = false
//        self.contentView.addSubview(textLabel)
//        NSLayoutConstraint.activate([
//            self.contentView.centerXAnchor.constraint(equalTo: textLabel.centerXAnchor),
//            self.contentView.centerYAnchor.constraint(equalTo: textLabel.centerYAnchor),
//        ])
//        self.textLabel = textLabel
//        self.textLabel.textColor = UIColor.white
//        self.reset()
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        self.reset()
//    }
//    
//    func reset() {
//        self.textLabel.textAlignment = .center
//    }
//}
//
//enum DeviceType {
//    
//    //MARK: - iPhones
//    /**
//     iPhone 5, iPhone 5S, iPhone 5C, iPhone SE 1st gen
//     */
//    case iPhoneSE1
//    
//    /**
//     iPhone 6, iPhone 6S, iPhone 7, iPhone 8, iPhone SE 2nd gen
//     */
//    case iPhoneSE2
//    
//    /**
//     iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus, iPhone 8 Plus
//     */
//    case iPhone8Plus
//    
//    /**
//     iPhone X, iPhone XS, iPhone 11 Pro
//     */
//    case iPhoneX
//    
//    /**
//     iPhone XR, iPhone 11
//     */
//    case iPhone11
//    
//    /**
//     iPhone XS Max, iPhone 11 Pro Max
//     */
//    case iPhone11ProMax
//    
//    
//    //MARK: - iPads
//    
//    /**
//     iPad Mini 2nd, 3rd, 4th and 5th Generation
//     */
//    case iPadMini
//    
//    /**
//     iPad 3rd, iPad 4th, iPad Air 1st, iPad Air 2nd, iPad Pro 9.7-inch, iPad 5th, iPad 6th Generation
//     */
//    case iPad9_7
//    
//    /**
//     iPad 7th Generation
//     */
//    case iPad10_2
//    
//    /**
//     iPad Pro 10.5, iPad Air 3rd Generation
//     */
//    case iPad10_5
//    
//    /**
//     iPad Pro 11-inch 1st and 2nd Generation
//     */
//    case iPadPro11
//    
//    /**
//     iPad Pro 12.9-inch 1st, 2nd, 3rd and 4th Generation
//     */
//    case iPadPro12
//    
//    func getSize() -> CGSize {
//        switch self {
//            
//        case .iPhoneSE1:
//            return CGSize(width: 320, height: 568)
//        case .iPhoneSE2:
//            return CGSize(width: 375, height: 667)
//        case .iPhone8Plus:
//            return CGSize(width: 414, height: 736)
//        case .iPhoneX:
//            return CGSize(width: 375, height: 812)
//        case .iPhone11:
//            return CGSize(width: 414, height: 896)
//        case .iPhone11ProMax:
//            return CGSize(width: 414, height: 896)
//        case .iPadMini:
//            return CGSize(width: 768, height: 1024)
//        case .iPad9_7:
//            return CGSize(width: 768, height: 1024)
//        case .iPad10_2:
//            return CGSize(width: 810, height: 1080)
//        case .iPad10_5:
//            return CGSize(width: 834, height: 1112)
//        case .iPadPro11:
//            return CGSize(width: 834, height: 1194)
//        case .iPadPro12:
//            return CGSize(width: 1024, height: 1366)
//        }
//    }
//    func getName() -> String {
//        switch self {
//        case .iPhoneSE1:
//            return "iPhone SE"
//        case .iPhoneSE2:
//            return "iPhone SE2"
//        case .iPhone8Plus:
//            return "iPhone 8+"
//        case .iPhoneX:
//            return "iPhone X"
//        case .iPhone11:
//            return "iPhone 11"
//        case .iPhone11ProMax:
//            return "iPhone 11 Pro Max"
//        case .iPadMini:
//            return "iPad Mini"
//        case .iPad9_7:
//            return "iPad 9.7"
//        case .iPad10_2:
//            return "iPad 10.2"
//        case .iPad10_5:
//            return "iPad 10.5"
//        case .iPadPro11:
//            return "iPad Pro 11"
//        case .iPadPro12:
//            return "iPad Pro 12"
//        }
//    }
//}
//
////extension FloatingPoint {
////    var degreesToRadians: Self { return self * .pi / 180 }
////    var radiansToDegrees: Self { return self * 180 / .pi }
////}
//extension UIApplication {
//    
//    func getKeyWindow() -> UIWindow? {
//        if #available(iOS 13, *) {
//            return windows.first { $0.isKeyWindow }
//        } else {
//            return keyWindow
//        }
//    }
//    
//    func makeSnapshot() -> UIImage? { return getKeyWindow()?.layer.makeSnapshot() }
//}
//
//
//extension CALayer {
//    func makeSnapshot() -> UIImage? {
//        let scale = UIScreen.main.scale
//        UIGraphicsBeginImageContextWithOptions(frame.size, false, scale)
//        defer { UIGraphicsEndImageContext() }
//        guard let context = UIGraphicsGetCurrentContext() else { return nil }
//        render(in: context)
//        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
//        return screenshot
//    }
//}
//
//extension UIView {
//    func makeSnapshot() -> UIImage? {
//        if #available(iOS 10.0, *) {
//            let renderer = UIGraphicsImageRenderer(size: frame.size)
//            return renderer.image { _ in drawHierarchy(in: bounds, afterScreenUpdates: true) }
//        } else {
//            return layer.makeSnapshot()
//        }
//    }
//}
//
//extension UIImage {
//    convenience init?(snapshotOf view: UIView) {
//        guard let image = view.makeSnapshot(), let cgImage = image.cgImage else { return nil }
//        self.init(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
//    }
//}
//
//
//
//var screenBounds: CGRect {
//    get {
//        if projectorActivated {
//            if Thread.current.isMainThread {
//                if #available(iOS 13.0, *) {
//                    if let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation {
//                        if orientation.isPortrait {
//                            return CGRect(x: 0, y: 0, width: ProjectorConfiguration.projectedScreenPortraitSize.width, height: ProjectorConfiguration.projectedScreenPortraitSize.height)
//                        } else {
//                            return CGRect(x: 0, y: 0, width: ProjectorConfiguration.projectedScreenPortraitSize.height, height: ProjectorConfiguration.projectedScreenPortraitSize.width)
//                        }
//                    } else {
//                        return CGRect(x: 0, y: 0, width: ProjectorConfiguration.projectedScreenPortraitSize.width, height: ProjectorConfiguration.projectedScreenPortraitSize.height)
//                    }
//                } else {
//                    
//                    let orientation = UIApplication.shared.statusBarOrientation
//                    if orientation.isPortrait {
//                        return CGRect(x: 0, y: 0, width: ProjectorConfiguration.projectedScreenPortraitSize.width, height: ProjectorConfiguration.projectedScreenPortraitSize.height)
//                    } else {
//                        return CGRect(x: 0, y: 0, width: ProjectorConfiguration.projectedScreenPortraitSize.height, height: ProjectorConfiguration.projectedScreenPortraitSize.width)
//                    }
//                    
//                }
//            } else {
//                return DispatchQueue.main.sync {
//                    if #available(iOS 13.0, *) {
//                        if let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation {
//                            if orientation.isPortrait {
//                                return CGRect(x: 0, y: 0, width: ProjectorConfiguration.projectedScreenPortraitSize.width, height: ProjectorConfiguration.projectedScreenPortraitSize.height)
//                            } else {
//                                return CGRect(x: 0, y: 0, width: ProjectorConfiguration.projectedScreenPortraitSize.height, height: ProjectorConfiguration.projectedScreenPortraitSize.width)
//                            }
//                        } else {
//                            return CGRect(x: 0, y: 0, width: ProjectorConfiguration.projectedScreenPortraitSize.width, height: ProjectorConfiguration.projectedScreenPortraitSize.height)
//                        }
//                        
//                    } else {
//                        let orientation = UIApplication.shared.statusBarOrientation
//                        
//                        if orientation.isPortrait {
//                            return CGRect(x: 0, y: 0, width: ProjectorConfiguration.projectedScreenPortraitSize.width, height: ProjectorConfiguration.projectedScreenPortraitSize.height)
//                        } else {
//                            return CGRect(x: 0, y: 0, width: ProjectorConfiguration.projectedScreenPortraitSize.height, height: ProjectorConfiguration.projectedScreenPortraitSize.width)
//                        }
//                    }
//                }
//            }
//        } else {
//            return UIScreen.main.bounds
//        }
//    }
//}
//
//enum SwapPosition {
//    
//    /**
//     This is default (depends on you phone and the phone that you want to simulate).
//     
//     If the iPhone that you want to simulate is __skinnier__ than yours, it will be centered horizontically, and the gap with the controls will be evenly ditributed on the left and right.
//     
//     If it's __wider__, it will be centered vertically, and the gap with the controls will be evenly ditributed on the top and bottom.
//     */
//    case centered
//    
//    /**
//     The simulated screen will stick to the __left__ of your phone, and the gap with the controls will be on the right.
//     
//     Only works if the iPhone that you want to simulate is __skinnier__ than yours
//     */
//    case left
//    
//    /**
//     The simulated screen will stick to the __right__  of your phone, and the gap with the controls will be on the left.
//     
//     Only works if the iPhone that you want to simulate is __skinnier__ than yours
//     */
//    case right
//    
//    /**
//     The simulated screen will stick to the __top__ of your phone, and the gap with the controls will be on the bottom.
//     
//     Only works if the iPhone that you want to simulate is __wider__ than yours
//     */
//    case top
//    
//    /**
//     The simulated screen will stick to the __bottom__ of your phone, and the gap with the controls will be on the top.
//     
//     Only works if the iPhone that you want to simulate is __wider__ than yours
//     */
//    case bottom
//}
//
//class PassView: UIView {}
//class OverlayControlsWindow: UIWindow {
//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        if let hitView = super.hitTest(point, with: event) {
//            if hitView.isKind(of: PassView.self) {
//                return nil
//            }
//            return hitView
//        }
//        return nil
//    }
//}
//
////Update system volume
//extension MPVolumeView {
//    static func setVolume(_ volume: Float) {
//        let volumeView = MPVolumeView()
//        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
//            slider?.value = volume
//        }
//    }
//}
//
//
//extension UIView {
//    func setAnchorPoint(_ point: CGPoint) {
//        var newPoint = CGPoint(x: bounds.size.width * point.x, y: bounds.size.height * point.y)
//        var oldPoint = CGPoint(x: bounds.size.width * layer.anchorPoint.x, y: bounds.size.height * layer.anchorPoint.y);
//        
//        newPoint = newPoint.applying(transform)
//        oldPoint = oldPoint.applying(transform)
//        
//        var position = layer.position
//        
//        position.x -= oldPoint.x
//        position.x += newPoint.x
//        
//        position.y -= oldPoint.y
//        position.y += newPoint.y
//        
//        layer.position = position
//        layer.anchorPoint = point
//    }
//}
//
//
//
//protocol ReturnCode: class {
//    func returnCode(image: UIImage)
//}
//class Projector {
//    
//    weak var returnAztecCode: ReturnCode?
//    static var collectionWindow: UIWindow?
//    
//    static func showFakeStatusBar() {
//        if projectorActivated {
//            
//        }
//    }
//    static func returnAllowedOrientationsFor(_ window: UIWindow) -> UIInterfaceOrientationMask {
//        if ProjectorConfiguration.settings.shouldShowControls {
//            if #available(iOS 13.0, *) {
//                if let orientation = ProjectorConfiguration.rootWindow.windowScene?.interfaceOrientation {
//                    if ProjectorConfiguration.initializedCollectionController == true {
//                        if orientation.isLandscape {
//                            
//                            ProjectorConfiguration.collectionController.disableMenuPress()
//                        } else {
//                            ProjectorConfiguration.collectionController.enableMenuPress()
//                        }
//                    }
//                }
//            } else {
//                let orientation = UIApplication.shared.statusBarOrientation
//                if ProjectorConfiguration.initializedCollectionController == true {
//                    if orientation.isLandscape {
//                        
//                        ProjectorConfiguration.collectionController.disableMenuPress()
//                    } else {
//                        ProjectorConfiguration.collectionController.enableMenuPress()
//                    }
//                }
//                
//                
//                // Fallback on earlier versions
//            }
//        }
//        
//        if ProjectorConfiguration.collectionWindow == window {
//            return .portrait
//        }
//        return .all
//    }
//    
//    static func makeControlsView(rootWindow: UIWindow, rect: CGRect) {
//        if projectorActivated {
//            #if DEBUG
//            
//            if #available(iOS 13.0, *) {
//                if let currentScene = rootWindow.windowScene {
//                    collectionWindow = OverlayControlsWindow(windowScene: currentScene)
//                    collectionWindow?.frame = UIScreen.main.bounds
//                    collectionWindow?.windowLevel = UIWindow.Level.alert + 1
//                    
//                    let collectionView = ProjectorCollectionViewController()
//                    //                collectionView.projectedRect = rect
//                    let xValue = rect.origin.x
//                    let yValue = rect.origin.y
//                    let wValue = rect.size.width
//                    let hValue = rect.size.height
//                    
//                    let roundedXValue = round(1000 * xValue)/1000
//                    let roundedYValue = round(1000 * yValue)/1000
//                    let roundedWValue = round(1000 * wValue)/1000
//                    let roundedHValue = round(1000 * hValue)/1000
//                    
//                    //                print("INIT copyboard: \(roundedXValue)=\(roundedYValue)=\(roundedWValue)=\(roundedHValue)")
//                    collectionView.rectStringForCopying = "\(roundedXValue)=\(roundedYValue)=\(roundedWValue)=\(roundedHValue)=\(ProjectorConfiguration.statusBarHeight)"
//                    
//                    collectionWindow?.rootViewController = collectionView
//                    collectionWindow?.makeKeyAndVisible()
//                    
//                    if let window = self.collectionWindow {
//                        ProjectorConfiguration.collectionWindow = window
//                    }
//                }
//                
//            } else {
//                collectionWindow = OverlayControlsWindow()
//                collectionWindow?.frame = UIScreen.main.bounds
//                collectionWindow?.windowLevel = UIWindow.Level.alert + 1
//                
//                let collectionView = ProjectorCollectionViewController()
//                //                collectionView.projectedRect = rect
//                let xValue = rect.origin.x
//                let yValue = rect.origin.y
//                let wValue = rect.size.width
//                let hValue = rect.size.height
//                
//                let roundedXValue = round(1000 * xValue)/1000
//                let roundedYValue = round(1000 * yValue)/1000
//                let roundedWValue = round(1000 * wValue)/1000
//                let roundedHValue = round(1000 * hValue)/1000
//                
//                collectionView.rectStringForCopying = "\(roundedXValue)=\(roundedYValue)=\(roundedWValue)=\(roundedHValue)=\(ProjectorConfiguration.statusBarHeight)"
//                
//                collectionWindow?.rootViewController = collectionView
//                collectionWindow?.makeKeyAndVisible()
//                
//                if let window = self.collectionWindow {
//                    ProjectorConfiguration.collectionWindow = window
//                }
//            }
//            
//            
//            #endif
//        }
//    }
//    static func display(rootWindow: UIWindow, settings: ProjectorSettings) {
//        if projectorActivated {
//            #if DEBUG
//            
//            ProjectorConfiguration.rootWindow = rootWindow
//            ProjectorConfiguration.settings = settings
//            ProjectorConfiguration.currentIndex = ProjectorConfiguration.devices.firstIndex(of: settings.defaultDeviceToProject) ?? 0
//            
//            if #available(iOS 13.0, *) {
//                if let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation {
//                    if orientation.isLandscape {
//                        ProjectorConfiguration.isLandscape = true
//                    } else {
//                        ProjectorConfiguration.isLandscape = false
//                    }
//                }
//            } else {
//                let orientation = UIApplication.shared.statusBarOrientation
//                if orientation.isLandscape {
//                    ProjectorConfiguration.isLandscape = true
//                } else {
//                    ProjectorConfiguration.isLandscape = false
//                }
//            }
//            
//            var statusBarHeight = CGFloat(0)
//            var originalSize = CGSize(width: rootWindow.frame.size.width, height: rootWindow.frame.size.height)
//            if settings.shouldStopAtStatusBar == true {
//                
//                if #available(iOS 13.0, *) {
//                    statusBarHeight = ProjectorConfiguration.rootWindow.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
//                    originalSize.height -= statusBarHeight
//                    ProjectorConfiguration.statusBarHeight = statusBarHeight
//                } else {
//                    statusBarHeight = UIApplication.shared.statusBarFrame.height
//                    originalSize.height -= statusBarHeight
//                    ProjectorConfiguration.statusBarHeight = statusBarHeight
//                    
//                }
//                
//                
//            } else {
//                
//                ProjectorConfiguration.statusBarHeight = 0
//            }
//            
//            ProjectorConfiguration.originalSize = originalSize
//            
//            Projector.project(device: settings.defaultDeviceToProject) { rect in
//                if settings.shouldShowControls {
//                    Projector.makeControlsView(rootWindow: rootWindow, rect: rect)
//                }
//            }
//            #endif
//        }
//    }
//    static func project(device: DeviceType, handler:@escaping (_ rect: CGRect)-> Void) {
//        
//        let settings = ProjectorConfiguration.settings
//        ProjectorConfiguration.simulatedDevice = device
//        var newSize = device.getSize()
//        
//        let originalSize = ProjectorConfiguration.originalSize
//        
//        if ProjectorConfiguration.isLandscape {
//            newSize = CGSize(width: newSize.height, height: newSize.width)
//        }
//        
//        let originalWidth = originalSize.width
//        let originalHeight = originalSize.height
//        let originalAspectRatio = originalWidth / originalHeight
//        
//        let newWidth = newSize.width
//        let newHeight = newSize.height
//        let newAspectRatio = newWidth / newHeight
//        
//        let halfOrigWidth = originalWidth / 2
//        let halfOrigHeight = originalHeight / 2
//        
//        let halfNewWidth = newWidth / 2
//        let halfNewHeight = newHeight / 2
//        
//        var percentOfNew = CGFloat(0)
//        var percentOfOld = CGFloat(0)
//        
//        var projectedDeviceIsSkinnier = false
//        if originalAspectRatio < newAspectRatio {
//            projectedDeviceIsSkinnier = false
//            percentOfNew = originalWidth / newWidth
//            percentOfOld = newWidth / originalWidth
//        } else if originalAspectRatio > newAspectRatio {
//            projectedDeviceIsSkinnier = true
//            percentOfNew = originalHeight / newHeight
//            percentOfOld = newHeight / originalHeight
//        }
//        
//        var newOrigin = CGPoint(x: 0, y: 0)
//        
//        let normalX = halfOrigWidth - halfNewWidth
//        let normalY = halfOrigHeight - halfNewHeight
//        
//        let newWidthConvertedToOriginal = newWidth * percentOfNew
//        let newHeightConvertedToOriginal = newHeight * percentOfNew
//        
//        var frameForCropping = CGRect()
//        switch settings.position {
//        case .centered:
//            newOrigin.x = normalX
//            newOrigin.y = normalY
//            if projectedDeviceIsSkinnier {
//                let xValue = (originalWidth - newWidthConvertedToOriginal) / 2
//                frameForCropping = CGRect(x: xValue, y: 0, width: percentOfNew * newWidth, height: percentOfNew * newHeight)
//            } else {
//                let yValue = (originalHeight - newHeightConvertedToOriginal) / 2
//                frameForCropping = CGRect(x: 0, y: yValue, width: percentOfNew * newWidth, height: percentOfNew * newHeight)
//            }
//        case .left:
//            let convertedOriginalWidth = originalHeight * newAspectRatio
//            let newConverted = convertedOriginalWidth * percentOfOld
//            let diff = (convertedOriginalWidth - newConverted) / 2
//            newOrigin.x = diff
//            newOrigin.y = normalY
//            frameForCropping = CGRect(x: 0, y: 0, width: percentOfNew * newWidth, height: percentOfNew * newHeight)
//        case .right:
//            let convertedOriginalWidth = originalHeight * newAspectRatio
//            let newConverted = convertedOriginalWidth * percentOfOld
//            let normalXCoordinate = originalWidth - convertedOriginalWidth
//            var diff = (convertedOriginalWidth - newConverted) / 2
//            diff += normalXCoordinate
//            newOrigin.x = diff
//            newOrigin.y = normalY
//            let xValue = originalWidth - newWidthConvertedToOriginal
//            frameForCropping = CGRect(x: xValue, y: 0, width: percentOfNew * newWidth, height: percentOfNew * newHeight)
//        case .top:
//            let convertedOriginalHeight = originalWidth * (1 / newAspectRatio)
//            let newConverted = convertedOriginalHeight * percentOfOld
//            let diff = (convertedOriginalHeight - newConverted) / 2
//            newOrigin.x = normalX
//            newOrigin.y = diff
//            frameForCropping = CGRect(x: 0, y: 0, width: percentOfNew * newWidth, height: percentOfNew * newHeight)
//        case .bottom:
//            let convertedOriginalHeight = originalWidth * (1 / newAspectRatio)
//            let newConverted = convertedOriginalHeight * percentOfOld
//            let normalYCoordinate = originalHeight - convertedOriginalHeight
//            var diff = (convertedOriginalHeight - newConverted) / 2
//            diff += normalYCoordinate
//            newOrigin.x = normalX
//            newOrigin.y = diff
//            let yValue = originalHeight - newHeightConvertedToOriginal
//            frameForCropping = CGRect(x: 0, y: yValue, width: percentOfNew * newWidth, height: percentOfNew * newHeight)
//        }
//        
//        frameForCropping.origin.y += ProjectorConfiguration.statusBarHeight
//        //        ProjectorConfiguration.currentFrameForCropping = frameForCropping
//        
//        
//        
//        newOrigin.y += ProjectorConfiguration.statusBarHeight
//        
//        UIView.animate(withDuration: 0.2, animations: {
//            ProjectorConfiguration.rootWindow.transform = CGAffineTransform.identity
//        }) { _ in
//            UIView.animate(withDuration: 0.5, animations: {
//                ProjectorConfiguration.rootWindow.frame.origin = newOrigin
//                ProjectorConfiguration.rootWindow.frame.size.width = newWidth
//                ProjectorConfiguration.rootWindow.frame.size.height = newHeight
//                ProjectorConfiguration.rootWindow.transform = CGAffineTransform(scaleX: percentOfNew, y: percentOfNew)
//            }) { _ in
//                handler(ProjectorConfiguration.rootWindow.frame)
//            }
//        }
//        
//    }
//}
//extension CIImage {
//    func convertToUIImage() -> UIImage {
//        let context: CIContext = CIContext.init(options: nil)
//        let cgImage: CGImage = context.createCGImage(self, from: self.extent)!
//        let image: UIImage = UIImage.init(cgImage: cgImage)
//        return image
//    }
//}
//
//
//var projectorActivated = false
//
//class ProjectorSettings: NSObject {
//    
//    var shouldStopAtStatusBar = true
//    var position = SwapPosition.centered
//    var defaultDeviceToProject = DeviceType.iPhoneX
//    var shouldShowControls = true
//}
//
//class ProjectorConfiguration: NSObject {
//    
//    static var originalVolume = Float(0.5)
//    static var isLandscape = false
//    
//    static var rootWindow = UIWindow()
//    
//    static var collectionWindow = UIWindow()
//    static var collectionController = ProjectorCollectionViewController()
//    static var initializedCollectionController = false
//    
//    //    static var currentFrameForCropping = CGRect(x: 0, y: 0, width: 500, height: 500)
//    static var projectedScreenPortraitSize = CGSize(width: 0, height: 0)
//    static var settings = ProjectorSettings()
//    static var simulatedDevice = DeviceType.iPhoneX
//    static var originalSize = CGSize(width: 0, height: 0)
//    static var statusBarHeight = CGFloat(0)
//    static var devices: [DeviceType] = [.iPhoneSE1, .iPhoneSE2, .iPhone8Plus, .iPhoneX, .iPhone11, .iPhone11ProMax, .iPadMini, .iPad9_7, .iPad10_2, .iPad10_5, .iPadPro11, .iPadPro12]
//    
//    static var currentIndex = 0
//    
//}
//
//
//
//
//
//
