//
//  UniversalSupport.swift
//  UniversalSupport
//
//  Created by Benoit Pereira da silva on 22/11/2018.
//  Copyright © 2018 https://pereira-da-silva.com. All rights reserved.
//

// UI basic universal support

#if os(iOS)
import UIKit
#elseif os(tvOS)
import TVUIKit
#elseif os(macOS)
import AppKit
#endif

import CoreGraphics

// We prefer to refer to XRect than CGRect
// To point that we are using universal support
public typealias XRect = CGRect
public typealias XPoint = CGPoint
public typealias XSize = CGSize

// MARK:-  iOS and tvOS neutral support

#if os(iOS) || os(tvOS)

import UIKit

public typealias XColor = UIColor

public typealias XView = UIView

public typealias XImage = UIImage

public typealias XFont = UIFont

public typealias XStoryboardSegue = UIStoryboardSegue

public typealias XBezierPath = UIBezierPath

public typealias XAffineTransform = CGAffineTransform
public extension XAffineTransform{

    public mutating func rotatedByDegrees(_ degrees: CGFloat) -> XAffineTransform{
        let radians : Float = degreesToRadians(angle: Float(degrees))
        return self.rotated(by: CGFloat(radians) )
    }
}

public extension XRect{
    public func clip(){
        // @todo ... use for compatibility with cocoa calls
        // Not sure it is useful
    }
}

public typealias XGraphicContext = CGContext

public extension XGraphicContext{

    public static var current:XGraphicContext? {
        return UIGraphicsGetCurrentContext()
    }

    public static var currentCGContext:CGContext? { return XGraphicContext.current }

    public static  func restore(){
        self.current?.restoreGState()
    }

    public static func save(){
        self.current?.saveGState()
    }

}

open class XImageView: UIImageView{}

open class XViewController: UIViewController{}

open class XTableView: UITableView{}

open class XTextView: UITextView{}

open class XTextField:UITextField{}

open class XSecureTextField:UITextField{}

open class XButton:UIButton{
    public  var title:String? {
        didSet{
            self.titleLabel?.text = title
        }
    }
}

#elseif os(watchOS)
// Not supported

#elseif os(macOS)

// MARK:-  mac OS attempt to look like iOS

import AppKit

public typealias XColor = NSColor

open class XView:NSView{

    public override init(frame frameRect: XRect){
        super.init(frame: frameRect)
    }

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }

    // Use iOS flipped coordinate system.
    open override var isFlipped: Bool {return true }

    open func setNeedsDisplay(){
        self.needsDisplay = true
    }
}

public typealias XImage = NSImage

public typealias XFont = NSFont

public typealias XStoryboardSegue = NSStoryboardSegue
public extension XStoryboardSegue{
    var destination:Any{
        get{
            return self.destinationController
        }
    }
}


public typealias XBezierPath = NSBezierPath
public extension XBezierPath{
    // iOS compatibility
    public convenience init(roundedRect rect: XRect, cornerRadius: CGFloat){
        self.init(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
    }
    public func addLine(to point: CGPoint){ self.line(to:point) }

    public func apply(_ transform: XAffineTransform){
        self.transform(using: transform)
    }
}

public typealias XAffineTransform = AffineTransform
public extension XAffineTransform {
    // iOS compatibility
    public init(translationX tx: CGFloat, y ty: CGFloat){
        self.init()
        self.translate(x: tx, y: ty)
    }

    public init(rotationAngle:CGFloat){
        self.init(rotationByDegrees: rotationAngle)
    }
    public mutating func translatedBy(x: CGFloat, y: CGFloat) -> XAffineTransform{
        self.translate(x: x, y: y)
        return self
    }
    public mutating func scaledBy(x: CGFloat, y: CGFloat) -> XAffineTransform{
        self.scale(x: x, y: y)
        return self
    }

    public mutating func rotatedByDegrees(_ degrees: CGFloat) -> XAffineTransform{
        self.rotate(byDegrees: degrees)
        return self
    }
}

public typealias XGraphicContext = NSGraphicsContext

public extension XGraphicContext {

    public static var currentCGContext:CGContext? { return XGraphicContext.current?.cgContext}


    public static func restore(){
        XGraphicContext.restoreGraphicsState()
    }
    public static func save(){
        XGraphicContext.saveGraphicsState()
    }
}


open class XImageView: NSImageView{}

open class XViewController: NSViewController{


    open func dismiss(animated flag: Bool, completion: (() -> Void)? = nil){
        self.dismiss(nil)
        completion?()
    }

    // iOS compatibility
    open func viewDidAppear(_ animated:Bool){
        super.viewDidAppear()
    }
    open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear()
    }
    open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear()
    }
    open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear()
    }

    override open func viewDidAppear() {
        self.viewDidAppear(false)
    }
    override open func viewWillAppear() {
        self.viewWillAppear(false)
    }
    override open func viewWillDisappear() {
        self.viewWillDisappear(false)
    }
    override open func viewDidDisappear() {
        self.viewDidDisappear(false)
    }

}

open class XWindowController: NSWindowController{}

open class XTableView: NSTableView{}

open class XTextView: NSTextView{
    /// iOS compatibility
    open var text:String {
        set{ self.string = newValue }
        get{ return self.string }
    }
}

open class XTextField:NSTextField{
    /// iOS compatibility
    open var text:String?{
        set{
            if let value = newValue{
                // String value is not optionnal
                self.stringValue = value
            }
        }
        get{
            return self.stringValue
        }
    }
}

open class XSecureTextField:NSSecureTextField{
    /// iOS compatibility
    open var text:String? {
        set{
            if let value = newValue{
                // String value is not optionnal
                self.stringValue = value
            }
        }
        get{
            return self.stringValue
        }
    }
}

open class XButton:NSButton{
}

#endif

// MARK:- Universal global functions

public func degreesToRadians(angle:Float)->Float{
    return (angle * .pi) / Float(180)
}

public func centeredRotation(rect:XRect,byDegrees angle:Float)->XAffineTransform{
    let center = XPoint(x: rect.midX, y: rect.midY)
    return anchoredRotation(anchorPoint: center, rect: rect, byDegrees: angle)
}

public func anchoredRotation(anchorPoint:XPoint,rect:XRect,byDegrees angle:Float)->XAffineTransform{
    var transform = XAffineTransform.identity
    transform = transform.translatedBy(x:anchorPoint.x, y:anchorPoint.y)
    transform = transform.rotatedByDegrees(CGFloat(angle))
    transform = transform.translatedBy(x: -anchorPoint.x, y: -anchorPoint.y)
    return transform
}

public func centeredScaling(rect:XRect,sX:Float,sY:Float)->XAffineTransform{
    let center = XPoint(x: rect.midX, y: rect.midY)
    return anchoredScaling(anchorPoint: center, rect: rect, sX: sX, sY: sY)
}

public func anchoredScaling(anchorPoint:XPoint,rect:XRect,sX:Float,sY:Float)->XAffineTransform{
    var transform = XAffineTransform.identity
    transform = transform.translatedBy(x: anchorPoint.x, y: anchorPoint.y)
    transform = transform.scaledBy(x: CGFloat(sX), y: CGFloat(sY))
    transform = transform.translatedBy(x: -anchorPoint.x, y: -anchorPoint.y)
    return transform
}
