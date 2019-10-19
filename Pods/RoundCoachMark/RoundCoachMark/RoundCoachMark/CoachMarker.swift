//
//  CoachMarker.swift
//  RoundCoachMark
//
//  Created by Dima Choock on 17/12/2017.
//  Copyright © 2017 GPB DIDZHITAL. All rights reserved.
//

import UIKit

public class CoachMarker
{
    public struct MarkInfo
    {
        let position:CGPoint
        let aperture:CGFloat
        let control:Any?
        let textInfo:(String,String)?
        let info:Any?
        let infoView:CoachMarkInfoView?
    }
    
// MARK: - INIT
    
    public init(in container:UIView, infoPadding:CGFloat, tag:String? = nil) 
    {
        markerTag = tag
        marksContainer = container
        marksCanvas = CoachMarksCanvas(frame:container.bounds)
        marksCanvas.markInfo = DefaultCoachMarkInfoView(width:container.bounds.size.width - 2*infoPadding)
        setup()
    }
    public init(in container:UIView, infoView:CoachMarkInfoView, tag:String? = nil) 
    {
        markerTag = tag
        marksContainer = container
        marksCanvas = CoachMarksCanvas(frame:container.bounds)
        marksCanvas.markInfo = infoView
        setup()
    }
    private func setup()
    {
        guard let the_container = marksContainer else {return}
        the_container.addSubview(marksCanvas)
        marksCanvas.constrainFill(padding: CGPoint.zero)
        the_container.layoutIfNeeded()
        NotificationCenter.default.post(name:Events.CoachMarkerMarksRequest, object:self)
    }
    deinit 
    {
        destroy(completion:{print("deinit \(self)")})
    }
    
// MARK: - MARKS BLIND REGISTRATION INTERFACE
    
/// Use static registration methods below to add marks when CoachMarker not accessible abd presumably not exists. 
/// For example on viewDidLoad, viewWillAppear or on awakeFromNib of a controller or a control presenting the mark.
/// Use unregister method to prevent showing a mark for hidden or inactive controller, call it on viewWillDisappear for example.
/// Returned CoachMarkHandler has to be stored as long as the mark needs to be shown after each CoachMarker restart 
/// Discarding the handler (by hander = nil for example) works as the unregisterMark.
/// These methods are preferable for coach mark adding.
/// See <ref to example project> for usage examples
    
    @discardableResult static public func registerMark(position:CGPoint, aperture:CGFloat, title:String, info:String, control:Any? = nil, autorelease:Bool = true, markTag:String? = nil) ->CoachMarkHandler
    {
        let handler = CoachMarkHandler()
        handler.token = NotificationCenter.default.addObserver(forName:Events.CoachMarkerMarksRequest, object:nil, queue:OperationQueue.main)
        { note in
            guard let marker = note.object as? CoachMarker else {return}
            guard marker.tagsAccordance(markTag) else {return}
            marker.addMark(title:title, info:info, position:position, aperture:aperture, control:control)
            if autorelease {marker.handlers.append(handler)}
        }
        return handler
    }
    @discardableResult static public func registerMark(title:String, info:String, centerShift:CGPoint = CGPoint.zero, aperture:CGFloat = 0, control:UIView, autorelease:Bool = true, markTag:String? = nil) ->CoachMarkHandler
    {
        let handler = CoachMarkHandler()
        handler.token = NotificationCenter.default.addObserver(forName:Events.CoachMarkerMarksRequest, object:nil, queue:OperationQueue.main)
        { note in
            guard let marker = note.object as? CoachMarker else {return}
            guard marker.tagsAccordance(markTag) else {return}
            marker.addMark(title:title, info:info, centerShift:centerShift, aperture:aperture, control:control)
            if autorelease {marker.handlers.append(handler)}
        }
        return handler
    }
    
    @discardableResult static public func registerMark(position:CGPoint, aperture:CGFloat, info:Any, control:Any? = nil, autorelease:Bool = true, markTag:String? = nil) ->CoachMarkHandler
    {
        let handler = CoachMarkHandler()
        handler.token = NotificationCenter.default.addObserver(forName:Events.CoachMarkerMarksRequest, object:nil, queue:OperationQueue.main)
        { note in
            guard let marker = note.object as? CoachMarker else {return}
            guard marker.tagsAccordance(markTag) else {return}
            marker.addMark(position:position, aperture:aperture, info:info, control:control)
            if autorelease {marker.handlers.append(handler)}
        }
        return handler
    }
    @discardableResult static public func registerMark(position:CGPoint, aperture:CGFloat, info:Any?, infoView:CoachMarkInfoView, control:Any? = nil, autorelease:Bool = true, markTag:String? = nil) ->CoachMarkHandler
    {
        let handler = CoachMarkHandler()
        handler.token = NotificationCenter.default.addObserver(forName:Events.CoachMarkerMarksRequest, object:nil, queue:OperationQueue.main)
        { note in
            guard let marker = note.object as? CoachMarker else {return}
            guard marker.tagsAccordance(markTag) else {return}
            marker.addMark(position:position, aperture:aperture, info:info, infoView:infoView, control:control)
            if autorelease {marker.handlers.append(handler)}
        }
        return handler
    }
    static public func unregisterMark(_ handler:CoachMarkHandler)
    {
        NotificationCenter.default.removeObserver(handler.token)
    }
    
// MARK: - MARKS DIRECT REGISTRATION INTERFACE
    
/// Use direct adding methods below to add marks in simple situations when the marks and the CoachMarker are defined
/// in a common context of the same view controller for example.
/// See <ref to example project> for usage examples
    
    public func addMark(title:String, info:String, position:CGPoint, aperture:CGFloat, control:Any? = nil)
    {
        let mark = MarkInfo(position:position, aperture:aperture, control:control, textInfo:(title,info), info:nil, infoView:nil)
        marks.append(mark)
    }
    public func addMark(title:String, info:String, centerShift:CGPoint = CGPoint.zero, aperture:CGFloat = 0, control:UIView)
    {
        guard let control_superview = control.superview else 
        {
            print("The control's view is not in hierarchy. The mark cannot be aded")
            return 
        }
        let position = marksCanvas.convert(control.center, from:control_superview).applying(CGAffineTransform.identity.translatedBy(x: centerShift.x, y: centerShift.y))
        let the_aperture = aperture > 0 ? aperture : max(control.bounds.size.width, control.bounds.size.height) + 6
        let mark = MarkInfo(position:position, aperture:the_aperture, control:control, textInfo:(title,info), info:nil, infoView:nil)
        marks.append(mark)
    }

    
    
    public func addMark(position:CGPoint, aperture:CGFloat, info:Any, control:Any? = nil)
    {
        let mark = MarkInfo(position:position, aperture:aperture, control:control, textInfo:nil, info:info, infoView:nil)
        marks.append(mark)
    }
    
    public func addMark(position:CGPoint, aperture:CGFloat, info:Any?, infoView:CoachMarkInfoView, control:Any? = nil)
    {
        let mark = MarkInfo(position:position, aperture:aperture, control:control, textInfo:nil, info:info, infoView:infoView)
        marks.append(mark)
    }
    
    private func tagsAccordance(_ markTag:String?) ->Bool
    {
        if let marker_tag = markerTag
        {
            guard let mark_tag = markTag else {return false}
            return marker_tag == mark_tag
        }
        if let mark_tag = markTag
        {
            guard let marker_tag = markerTag else {return false}
            return mark_tag == marker_tag
        }
        return false
    }   
    
    
// MARK: - ACCESS INTERFACE

    public var currentInfoView:CoachMarkInfoView? {return marksCanvas.markInfo}
    public var marksCount:Int                     {return marks.count}
    public var nextMark:MarkInfo?                 {return marks.count==0 ? nil :marks[nextMarkIndex]}
    public func mark(_ index:Int) ->MarkInfo?     {return (marks.count==0 ? nil : (index<0 ? marks.first : (index>=marks.count ? marks.last : marks[index])))}

// MARK: - PLAY INTERFACE

    private var showCount:Int?
    private var animating:Bool = false
    private var tapRecognizer:UITapGestureRecognizer?
    private var playCompletion:(()->Void)?
    private var showTimer:Timer?
    private var destroyAfterPlay:Bool = true
    
    /// tapPlay - use when the only you need is to show all marks one after another with taps. 
    /// Marker discarded automatically, create new one if need to repeat tapPlay
    public func tapPlay(autoStart:Bool, destroyWhenFinished:Bool = true, completion:(()->Void)? = nil)
    {
        guard validateContainer(),
              let container = marksContainer else {return}
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(playNext))
        container.addGestureRecognizer(tapRecognizer!)
        playCompletion = completion
        destroyAfterPlay = destroyWhenFinished
        if autoStart {playNext(tapRecognizer!)}
    }
    
    /// autoPlay - use when you need is to show all marks one after another automatically after given time interval.
    // Marker discarded automatically, create new one if need to repeat autoPlay.
    /// Note: if interval is too small to allow mark appearence/disappearence animation to run smoothly, the rate will be automatically droped.
    public func autoPlay(delay:Double, interval:Double, destroyWhenFinished:Bool = true, completion:(()->Void)? = nil)
    {
        guard validateContainer() else {return}
        playCompletion = completion
        destroyAfterPlay = destroyWhenFinished
        if delay <= 0 
        {
            showTimer = Timer.scheduledTimer(withTimeInterval:interval, repeats:true, block:CoachMarker.playNext(self))
            showTimer?.fire()
        }
        else 
        {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC))
            {
                self.showTimer = Timer.scheduledTimer(withTimeInterval:interval, repeats:true, block:CoachMarker.playNext(self))
                self.showTimer?.fire()
            }
        }
    }
    
    @objc private func playNext(_ sender:Any)
    {
        guard !animating else {return}
        animating = true
        if showCount == nil {showCount = self.marksCount}
        if showCount! == 0
        {
            animating = false
            if sender is Timer {showTimer?.invalidate();showTimer = nil}
            if destroyAfterPlay 
            {
                playCompletion?()
                destroy 
                {[weak self] in 
                    self?.marksContainer?.removeFromSuperview();
                }
            }
            else                
            {
                marksCanvas.removeCurrentMark
                {
                    [weak self] in
                    self?.playCompletion?()
                    self?.marksContainer?.removeFromSuperview()
                }
            }
        }
        else
        {
            self.presentNextMark
            { [weak self] in
                self?.showCount! -= 1
                self?.animating = false
            }
        }
    }
    
// MARK: - CONTROL INTERFACE 
    
/// presentMark - shows the mark at the given index
/// dismissMark - hides currently shown mark
/// presentNextMark - cycle hiding/showing marks starting from the mark at 0
/// resetMarks - hides current mars, removes all added marks, re-adds marks registered with static registration methods
/// destroy - completely destruct the marker and removes it from view hierarchy, use destroy if something needs
/// to be done right after the marker removed. Discarding a marker (by marker = nil for example) performs destroy with
/// empty completion block
    
    public func presentMark(_ index:Int, completion:@escaping ()->Void)
    {
        guard marks.count > 0 else {return}
        guard let mark = mark(index) else {return}
        marksCanvas.replaceCurrentMark(with:mark, completion:completion)
    }
    public func dismissMark(completion:@escaping ()->Void)
    {
        marksCanvas.removeCurrentMark(completion:completion)
    }
    public func presentNextMark(completion:@escaping ()->Void)
    {
        guard marks.count > 0 else {return}
        presentMark(nextMarkIndex,completion:completion)
        nextMarkIndex = (nextMarkIndex+1)%marks.count
    }
    public func resetMarks(completion:@escaping ()->Void)
    {
        dismissMark(completion:completion)
        marks.removeAll()
        nextMarkIndex = 0
        DispatchQueue.main.async(execute:{NotificationCenter.default.post(name:Events.CoachMarkerMarksRequest, object:self)})
    }
    public func destroy(completion:@escaping ()->Void)
    {
        // Automatic un-registration staticaly registered marks, which handlers are not stored externally
        handlers.forEach 
        { handler in
            NotificationCenter.default.removeObserver(handler.token)
        }
        handlers.removeAll()
        if (marksContainer?.gestureRecognizers?.count ?? 0) > 0 
        {
            if let tap = tapRecognizer
            {
                tap.removeTarget(self, action:#selector(playNext))
                marksContainer?.removeGestureRecognizer(tap)
                tapRecognizer = nil
            }
        }
        playCompletion = nil
        // Clean up canvas
        marksCanvas.removeCurrentMark
        {
            [weak self] in
            self?.marksCanvas.removeFromSuperview()
            self?.marks.removeAll()
            completion()
        }
    }
    
    
// MARK: - CUSTOMIZATION INTERFACE
    
    public var defaultInfoViewTitleFont:UIFont = UIFont.systemFont(ofSize:20)
    {
        didSet{currentInfoView?.setTitleStyle(font: defaultInfoViewTitleFont, color: defaultInfoViewTitleColor)}
    }
    public var defaultInfoViewTextFont:UIFont = UIFont.systemFont(ofSize:16)
    {
        didSet{currentInfoView?.setTitleStyle(font: defaultInfoViewTitleFont, color: defaultInfoViewTitleColor)}
    }
    public var defaultInfoViewTitleColor:UIColor = UIColor.white
    {
        didSet{currentInfoView?.setTitleStyle(font: defaultInfoViewTitleFont, color: defaultInfoViewTitleColor)}
    }
    public var defaultInfoViewTextColor:UIColor = UIColor.white
    {
        didSet{currentInfoView?.setTitleStyle(font: defaultInfoViewTitleFont, color: defaultInfoViewTitleColor)}
    }
    public func setColors(main:UIColor, echo:UIColor) 
    {
        marksCanvas.ringMainColor=main
        marksCanvas.ringEchoColor=echo;
    }
    public func setDynamics(mainPeriod:Double, aperturePeriod:Double, echoTravel:CGFloat) 
    {
        marksCanvas.ringPeriod=mainPeriod
        marksCanvas.apPeriod=aperturePeriod
        marksCanvas.ecTravel=echoTravel
    }
    public func setEcho(beginOpacity:CGFloat, endOpacity:CGFloat)
    {
        marksCanvas.ecBeginOpacity=beginOpacity
        marksCanvas.ecEndOpacity=endOpacity
    }
    
// MARK: - PROPERTIES
    
    weak var marksContainer:UIView?
    var marksCanvas:CoachMarksCanvas
    
    var marks = [MarkInfo]()
    var handlers = [CoachMarkHandler]()
    var nextMarkIndex:Int = 0
    
    var markerTag:String?
    
    enum Events
    {
        public static let CoachMarkerMarksRequest = Notification.Name("CoachMarkerRegisterMarksRequest")
    }
    
// MARK: - AUX

    func validateContainer() ->Bool
    {
        guard let _ = marksContainer else {print("\(self) is not added into a view hierarchy. Check if the container view passed to the constructor exists and is in an hierarcy");return false}
        return true
    }
}

// MARK: - CoachMarkInfoView

public protocol CoachMarkInfoView: class
{
    var viewSize:CGSize      {get}
    var centerOffset:CGPoint {get}
    
    func setInfo(_ info:Any)
    
    func setTextInfo(title:String, info:String)
    func setTitleStyle(font:UIFont, color:UIColor)
    func setInfoStyle(font:UIFont, color:UIColor)
}

extension CoachMarkInfoView where Self: UIView{}

// MARK: - MarkControlHandler

public class CoachMarkHandler
{
    var token:NSObjectProtocol!
    internal init (){}
    deinit
    {
        print("MarkControlHandler deinit: \(self)")
        NotificationCenter.default.removeObserver(token)
    }
}

// MARK: - TYPICAL MARKS SHOWING CYCLE

extension CoachMarker
{
    static public func cycleAllMarksOnce(in marker:CoachMarker) ->Bool
    {
        // TODO: under construction. 
        return false
    }
}
