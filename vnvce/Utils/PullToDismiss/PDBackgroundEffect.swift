//
//  PDBackgroundEffect.swift
//  vnvce
//
//  Created by Kerem Cesme on 10.11.2022.
//

import Foundation
import UIKit

@objc public protocol PDBackgroundEffect: NSObjectProtocol {
    var color: UIColor? { get set }
    var alpha: CGFloat { get set }
    var target: PDBackgroundTarget { get }
    
    func makeBackgroundView() -> UIView
    func applyEffect(view: UIView?, rate: CGFloat)
}

/// A target type to add background view
///
/// - targetViewController: add background view to target viewcontroller
/// - presentingViewController: add background view to target viewcontroller's presenting viewcontroller
@objc public enum PDBackgroundTarget: Int {
    case targetViewController
    case presentingViewController
}

public final class PDShadowEffect: NSObject, PDBackgroundEffect {
    public var color: UIColor?
    public var alpha: CGFloat
    public var target: PDBackgroundTarget = .targetViewController

    @objc(defaultShadowEffedt)
    public static let `default`: PDShadowEffect = PDShadowEffect(color: .black, alpha: 0.8)
    
    public init(color: UIColor?, alpha: CGFloat) {
        self.color = color
        self.alpha = alpha
    }
    
    // only Objective-C
    @available(*, unavailable)
    public class func shadowEffect(color: UIColor?, alpha: CGFloat) -> PDShadowEffect {
        return PDShadowEffect(color: color, alpha: alpha)
    }
    
    
    public func makeBackgroundView() -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = color
        view.alpha = alpha
        return view
    }
    
    public func applyEffect(view: UIView?, rate: CGFloat) {
        view?.alpha = alpha * rate
    }
}

@available(iOS, introduced: 9.0)
public final class PDBlurEffect: NSObject, PDBackgroundEffect {
    public var color: UIColor?
    public var alpha: CGFloat
    public var blurRadius: CGFloat
    public var saturationDeltaFactor: CGFloat

    public var target: PDBackgroundTarget = .presentingViewController

    @objc(defaultBlur)
    public static let `default`: PDBlurEffect = PDBlurEffect(
        color: nil,
        alpha: 0.0,
        blurRadius: 20.0,
        saturationDeltaFactor: 1.8
    )
    
    @objc(extraLightBlurEffect)
    public static let extraLight: PDBlurEffect = PDBlurEffect(
        color: UIColor(white: 0.97, alpha: 0.82),
        alpha: 1.0,
        blurRadius: 20.0,
        saturationDeltaFactor: 1.8
    )
    
    @objc(lightBlurEffect)
    public static let light: PDBlurEffect = PDBlurEffect(
        color: UIColor(white: 1.0, alpha: 0.3),
        alpha: 1.0,
        blurRadius: 30.0,
        saturationDeltaFactor: 1.8
    )
    
    @objc(darkBlurEffect)
    public static let dark: PDBlurEffect = PDBlurEffect(
        color: UIColor(white: 0.11, alpha: 0.73),
        alpha: 1.0,
        blurRadius: 20.0,
        saturationDeltaFactor: 1.8
    )
    
    public init(color: UIColor?, alpha: CGFloat, blurRadius: CGFloat, saturationDeltaFactor: CGFloat) {
        self.color = color
        self.alpha = alpha
        self.blurRadius = blurRadius
        self.saturationDeltaFactor = saturationDeltaFactor
    }

    // only Objective-C
    @available(*, unavailable)
    public class func blurEffect(color: UIColor?, alpha: CGFloat, blurRadius: CGFloat, saturationDeltaFactor: CGFloat) -> PDBlurEffect {
        return PDBlurEffect(color: color, alpha: alpha, blurRadius: blurRadius, saturationDeltaFactor: saturationDeltaFactor)
    }
    
    public func makeBackgroundView() -> UIView {
        let view = PDCustomBlurView(radius: blurRadius)
        view.colorTint = color
        view.colorTintAlpha = alpha
        view.saturationDeltaFactor = saturationDeltaFactor
        return view
    }
    
    public func applyEffect(view: UIView?, rate: CGFloat) {
        guard let view = view as? PDCustomBlurView else {
            return
        }
        view.blurRadius = blurRadius * rate
        view.colorTintAlpha = alpha * rate
        view.saturationDeltaFactor = (saturationDeltaFactor - 1.0) * rate + 1.0
    }
}
