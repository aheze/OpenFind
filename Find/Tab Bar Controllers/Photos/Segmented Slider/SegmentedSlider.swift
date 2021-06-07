//
//  SegmentedSlider.swift
//  PhotoGallery
//
//  Created by Zheng on 12/30/20.
//

import UIKit

enum PhotoTutorialType {
    case starred
    case cached
    case local
    case screenshots
}
enum PhotoFilter {
    case local
    case screenshots
    case all
}
enum TouchStatus {
    case notStarted
    case startedInCurrentFilter /// touched down in current label
    case startedOutsideCurrentFilter /// touched down outside of current label
}

struct PhotoFilterState {
    var starSelected = false
    var cacheSelected = false
    var currentFilter = PhotoFilter.all
}
class SegmentedSlider: UIView {
    
    var pressedFilter: ((PhotoFilterState) -> Void)?
    
    var photoFilterState = PhotoFilterState()
        
    var touchStatus = TouchStatus.notStarted
    
    var currentHoveredFilter: PhotoFilter? /// filter selected via hovering
    var currentHoveredLabel: UIView?
    
    @IBOutlet var contentView: UIView!
    
    /// container for Local Screenshots Cached labels
    @IBOutlet var slidersView: UIView!
    
    /// contains Star + Cache + Container View
    @IBOutlet var baseView: UIView!
    @IBOutlet weak var containerView: UIView! /// for baseView
    
    @IBOutlet weak var starCacheContainerView: UIView!
    @IBOutlet weak var starImageView: UIImageView!
    @IBOutlet weak var cacheImageView: UIImageView!
    
    @IBOutlet weak var starButton: CustomButton!
    @IBAction func starButtonPressed(_ sender: Any) {
        print("star!!")
        photoFilterState.starSelected.toggle()
        pressedFilter?(photoFilterState)
    }
    
    @IBOutlet weak var cacheButton: CustomButton!
    @IBAction func cacheButtonPressed(_ sender: Any) {
        print("cache!!")
        photoFilterState.cacheSelected.toggle()
        pressedFilter?(photoFilterState)
    }
    
    @IBOutlet weak var sliderContainerView: UIView! /// contains slider and labels
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var indicatorView: UIView!
    
    @IBOutlet weak var localLabel: PaddedLabel!
    @IBOutlet weak var screenshotsLabel: PaddedLabel!
    @IBOutlet weak var allLabel: PaddedLabel!
    
    // MARK: Photos selection
    @IBOutlet var numberOfSelectedView: UIView!
    @IBOutlet weak var numberOfSelectedLabel: UILabel!
    var showingPhotosSelection = false
    
    var allowingInteraction = true
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if allowingInteraction {
            if let touchPoint = touches.first?.location(in: slidersView) {
                if let (hoveredLabel, hoveredFilter) = getHoveredLabel(touchPoint: touchPoint) as? (UIView, PhotoFilter) {
                    
                    if hoveredFilter == photoFilterState.currentFilter { /// dragging indicator
                        touchStatus = .startedInCurrentFilter
                        animateScale(shrink: true)
                    } else { /// pressed down on different label
                        touchStatus = .startedOutsideCurrentFilter
                        currentHoveredLabel = hoveredLabel
                        animateHighlight(view: hoveredLabel, highlight: true)
                    }
                    currentHoveredFilter = hoveredFilter
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if allowingInteraction {
            if let touchPoint = touches.first?.location(in: slidersView) {
                if let (hoveredLabel, hoveredFilter) = getHoveredLabel(touchPoint: touchPoint) as? (UIView, PhotoFilter) {
                    
                    if hoveredFilter != currentHoveredFilter { /// dragged to different label
                        if touchStatus == .startedInCurrentFilter {
                            animateChangeSelection(filter: hoveredFilter)
                        } else {
                            animateHighlight(view: hoveredLabel, highlight: true)
                            
                            if let currentHoveredLabel = currentHoveredLabel {
                                animateHighlight(view: currentHoveredLabel, highlight: false)
                            }
                            currentHoveredLabel = hoveredLabel
                            
                        }
                        currentHoveredFilter = hoveredFilter
                    }
                }
            }
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if allowingInteraction {
            if let touchPoint = touches.first?.location(in: slidersView) {
                if let (_, hoveredFilter) = getHoveredLabel(touchPoint: touchPoint) as? (UIView, PhotoFilter) {
                    if photoFilterState.currentFilter != hoveredFilter {
                        animateChangeSelection(filter: hoveredFilter)
                        photoFilterState.currentFilter = hoveredFilter
                        pressedFilter?(photoFilterState)
                    }
                }
                animateHighlight(view: localLabel, highlight: false)
                animateHighlight(view: screenshotsLabel, highlight: false)
                animateHighlight(view: allLabel, highlight: false)
                animateScale(shrink: false)
            }
        }
    }
    
    func cancelTouch(cancel: Bool) {
        if cancel {
            allowingInteraction = false
            animateChangeSelection(filter: photoFilterState.currentFilter)
            animateHighlight(view: localLabel, highlight: false)
            animateHighlight(view: screenshotsLabel, highlight: false)
            animateHighlight(view: allLabel, highlight: false)
            animateScale(shrink: false)
        } else {
            allowingInteraction = true
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("SegmentedSlider", owner: self, options: nil)
        
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        contentView.addSubview(baseView)
        baseView.frame = self.bounds
        baseView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        containerView.addSubview(slidersView)
        slidersView.frame = containerView.bounds
        slidersView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.clipsToBounds = true
        self.layer.borderWidth = 0.1
        self.layer.borderColor = UIColor.secondaryLabel.cgColor
        
        starButton.touched = { [weak self] down in
            if down {
                UIView.animate(withDuration: 0.2, animations: {
                    self?.starImageView.alpha = 0.5
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self?.starImageView.alpha = 1
                })
            }
        }
        cacheButton.touched = { [weak self] down in
            if down {
                UIView.animate(withDuration: 0.2, animations: {
                    self?.cacheImageView.alpha = 0.5
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self?.cacheImageView.alpha = 1
                })
            }
        }
        
        setupAccessibility()
    }
    
    override var accessibilityTraits: UIAccessibilityTraits {
        get {
            return showingPhotosSelection ? .none : .adjustable
        }
        set {
            super.accessibilityTraits = newValue
        }
    }
    override var accessibilityValue: String? {
        get {
            if showingPhotosSelection == false {
                switch photoFilterState.currentFilter {
                case .local:
                    return "Local"
                case .screenshots:
                    return "Screenshots"
                case .all:
                    return "All"
                }
            } else {
                return nil
            }
        }
        
        set {
            super.accessibilityValue = newValue
        }
    }
    
    override func accessibilityIncrement() {
        switch photoFilterState.currentFilter {
        case .local:
            photoFilterState.currentFilter = .screenshots
        case .screenshots:
            photoFilterState.currentFilter = .all
        case .all:
            break
        }
        animateChangeSelection(filter: photoFilterState.currentFilter)
        pressedFilter?(photoFilterState)
    }
    
    override func accessibilityDecrement() {
        switch photoFilterState.currentFilter {
        case .local:
            break
        case .screenshots:
            photoFilterState.currentFilter = .local
        case .all:
            photoFilterState.currentFilter = .screenshots
        }
        animateChangeSelection(filter: photoFilterState.currentFilter)
        pressedFilter?(photoFilterState)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.height / 2
        indicatorView.layer.cornerRadius = indicatorView.bounds.height / 2
    }
    
    func animateChangeSelection(filter: PhotoFilter) {
        let (_, frame) = getIndicatorViewFrame(for: filter, withInset: true)
        let centerX = frame.origin.x + frame.size.width / 2
        let centerY = frame.origin.y + frame.size.height / 2
        
        UIView.animate(withDuration: 0.2, animations: {
            self.indicatorView.bounds = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
            self.indicatorView.center = CGPoint(x: centerX, y: centerY)
        })
    }
    func animateHighlight(view: UIView, highlight: Bool) {
        if highlight {
            UIView.animate(withDuration: 0.2) {
                view.alpha = 0.5
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                view.alpha = 1
            }
        }
    }
    func animateScale(shrink: Bool) {
        if shrink {
            UIView.animate(withDuration: 0.2) {
                self.indicatorView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.indicatorView.transform = CGAffineTransform.identity
            }
        }
    }
    
    func getHoveredLabel(touchPoint: CGPoint) -> (UIView?, PhotoFilter?) {
        let (localLabel, localFrame) = getIndicatorViewFrame(for: .local, withInset: false)
        let (screenshotsLabel, screenshotsFrame) = getIndicatorViewFrame(for: .screenshots, withInset: false)
        let (allLabel, allFrame) = getIndicatorViewFrame(for: .all, withInset: false)
        
        var hoveredLabel: UIView?
        var hoveredFilter: PhotoFilter?
        
        var anyYTouchPoint = touchPoint
        anyYTouchPoint.y = stackView.bounds.height / 2
        switch true {
        case localFrame.contains(anyYTouchPoint):
            hoveredLabel = localLabel
            hoveredFilter = .local
        case screenshotsFrame.contains(anyYTouchPoint):
            hoveredLabel = screenshotsLabel
            hoveredFilter = .screenshots
        case allFrame.contains(anyYTouchPoint):
            hoveredLabel = allLabel
            hoveredFilter = .all
        default:
            break
        }
        return (hoveredLabel, hoveredFilter)
    }
    
    /// get label and its frame
    func getIndicatorViewFrame(for filter: PhotoFilter, withInset: Bool) -> (UIView, CGRect) {
        let labelFrame: CGRect
        let label: UIView
        switch filter {
        case .local:
            labelFrame = localLabel.frame
            label = localLabel
        case .screenshots:
            labelFrame = screenshotsLabel.frame
            label = screenshotsLabel
        case .all:
            labelFrame = allLabel.frame
            label = allLabel
        }
        
        if withInset {
            let x = (labelFrame.origin.x + 4) + stackView.frame.origin.x
            let y = labelFrame.origin.y + 4
            let width = labelFrame.width - 8
            let height = labelFrame.height - 8
            
            let indicatorFrame = CGRect(x: x, y: y, width: width, height: height)
            
            return (label, indicatorFrame)
        } else {
            return (label, labelFrame)
        }
    }
}
