//
//  FreeFunctions.swift
//  Scanner
//
//  Created by Vadym Yakovlev on 29.01.2020.
//  Copyright © 2020 Vadym Yakovlev. All rights reserved.
//

import CoreImage
import Foundation
import UIKit

// MARK: - Auxiliary functions

func compactMap<T>(_ input: [T?]) -> [T] {
	return input.compactMap(identity)
}

func benchmark(operationTitle: String? = nil, operation: () -> Void) {
    let startTime = CFAbsoluteTimeGetCurrent()
    operation()
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
    print("Time elapsed for \(operationTitle ?? "unknown"): \(timeElapsed) s.")
}

func notNil<E>(_ input: E?) -> Bool {
  return input.isNotNil
}

func isNil<E>(_ input: E?) -> Bool {
  return input.isNil
}

func toVoid(_ value: Any) -> Void {
  return Void()
}

func identity<T>(_ item: T) -> T {
  return item
}

func identityOp<T>(_ item: T) -> T? {
  return item
}

func isTrue(_ input: Bool) -> Bool {
  return input == true
}

func isFalse(_ input: Bool) -> Bool {
  return input == false
}

func toArray<E>(_ item: E) -> [E] {
  return [item]
}

// MARK: - Expand Optional -

/// Two optionals to one optional tuple
func zip2<A, B>(
  _ variant1: Optional<A>,
  _ variant2: Optional<B>
) -> Optional<(A, B)> {
  return variant1.flatMap { val1 in
    return variant2.flatMap { val2 in (val1, val2) }
  }
}

/// Three optionals to one optional tuple
func zip3<A, B, C>(
  _ variant1: Optional<A>,
  _ variant2: Optional<B>,
  _ variant3: Optional<C>
) -> Optional<(A, B, C)> {
  return variant1.flatMap { val1 in
    return variant2.flatMap { val2 in
      return variant3.flatMap { val3 in (val1, val2, val3) }
    }
  }
}

// MARK: - Global Queues Wrappers -

func onMainQueue(_ block: @escaping () -> Void) {
    DispatchQueue.main.async(execute: block)
}

func onGlobalUtilityQueue(_ block: @escaping () -> Void) {
    DispatchQueue.global(qos: .utility).async(execute: block)
}

// MARK: - Preprocessor Macros Wrappers -

/// Execute in a specific build configuration
func executeOn<T>(debug: () -> T, release: () -> T) -> T {
  #if DEBUG
  return debug()
  #else
  return release()
  #endif
}

/// Execute in a specific build configuration
func executeOn(debug: (() -> Void)? = nil, release: (() -> Void)? = nil) {
  executeOn(debug: debug ?? {}, release: release ?? {})
}

/// Execute on simulator or real device
func executeOn<T>(simulator: () -> T, device: () -> T) -> T {
  #if targetEnvironment(simulator)
  return simulator()
  #else
  return device()
  #endif
}

/// Execute on simulator or real device
func executeOn(simulator: (() -> Void)? = nil, device: (() -> Void)? = nil) {
  executeOn(simulator: simulator ?? {}, device: device ?? {})
}

/// Rotates input image relatively to anchor point
/// - Parameters:
///   - image: <#image description#>
///   - radians: <#radians description#>
///   - relativeAnchorPoint: <#relativeAnchorPoint description#>
/// - Returns: <#description#>
func rotate(image: CIImage,
            radians: CGFloat,
            relativeAnchorPoint: CGPoint = CGPoint(x: 0.5, y: 0.5)) -> CIImage {
  
  let extent = image.extent
  let anchor = CGPoint(x: extent.width * relativeAnchorPoint.x,
                       y: extent.height * relativeAnchorPoint.y)
  
  let t = CGAffineTransform.identity
    .translatedBy(x: anchor.x, y: anchor.y)
    .rotated(by: radians)
    .translatedBy(x: -anchor.x, y: -anchor.y)
  
  return image.transformed(by: t)
}

func rotateCurried(radians: CGFloat) -> (CIImage) -> CIImage {
  return { input in
    return rotate(image: input, radians: radians, relativeAnchorPoint: .init(x: 0.5, y: 0.5))
  }
}

func radians<T: FloatingPointMath>(_ degrees: T) -> T {
  return degrees * T.pi / T(180.0)
}

/// Scales input image relatively to anchor point
func scale(inputImage: CIImage,
           scale: CGSize,
           relativeAnchor: CGPoint = CGPoint(x: 0.5, y: 0.5)) -> CIImage {
  
  // scale transform
  let scaleTransform = CGAffineTransform.identity.scaledBy(x: scale.width, y: scale.height)
  let scaledImage = inputImage.transformed(by: scaleTransform)
  
  // translation transform to keep image aligned with anchor point
  let translationTransform =
    CGAffineTransform(translationX: (inputImage.extent.origin.x - scaledImage.extent.origin.x) + (inputImage.extent.width - scaledImage.extent.width) * relativeAnchor.x,
                      y: (inputImage.extent.origin.y - scaledImage.extent.origin.y) + (inputImage.extent.height - scaledImage.extent.height) * relativeAnchor.y)
  let translatedImage = scaledImage.transformed(by: translationTransform)
  return translatedImage
}

func * (lhs: CGPoint, rhs: CGSize) -> CGPoint {
  return .init(x: lhs.x * rhs.width, y: lhs.y * rhs.height)
}

func resample<T>(array: [T], toSize newSize: Int) -> [T] {
  guard !array.isEmpty else { return [] }
  let size = array.count
  return (0 ..< newSize).map { array[$0 * size / newSize] }
}

func transform<T: FloatingPointMath>(sourceValue: T,
                                     sourceScale: ClosedRange<T>,
                                     targetScaleScale: ClosedRange<T>) -> T {
  let a: T = targetScaleScale.lowerBound + (sourceValue - sourceScale.lowerBound)
  let b: T = targetScaleScale.upperBound - targetScaleScale.lowerBound
  let c: T = sourceScale.upperBound - sourceScale.lowerBound
  return a * b / c
}

func ifNaN<T: FloatingPoint>(_ value: T, fallback: T) -> T {
  if value.isNaN {
    return fallback
  } else {
    return value
  }
}

// MARK: - Policy Attributed Text

func recursively<T>(operation: (T) -> Void,
                    on target: T,
                    children: (T) -> [T]) {
  operation(target)
  children(target)
    .forEach { child in
      recursively(operation: operation,
                  on: child,
                  children: children)
  }
}

func time() -> String {
  let f = DateFormatter()
  f.dateFormat = "HH:mm:ss.SSS"
  return f.string(from: Date())
}

func drawRects(_ rects: [String: CGRect], canvas: CGRect? = nil) -> UIImage {
  let rawBounds = canvas ?? rects.values.reduce(CGRect.zero) { (res, elem) -> CGRect in
    return res.union(elem)
  }
  let bounds = rawBounds.insetBy(dx: -50, dy: -50)
  let labelAttrs: [NSAttributedString.Key : Any] = [.font: UIFont.systemFont(ofSize: 12), .foregroundColor: UIColor.black]

  let renderer = UIGraphicsImageRenderer(bounds: bounds)
  return renderer.image { (ctx) in
    UIColor.lightGray.setFill()
    let _bgPath = UIBezierPath(rect: bounds)
    ctx.cgContext.addPath(_bgPath.cgPath)
    _bgPath.fill()
    
    UIColor.white.setFill()
    let bgPath = UIBezierPath(rect: rawBounds)
    ctx.cgContext.addPath(bgPath.cgPath)
    bgPath.fill()
    
    rects.forEach { label, rect in
      let color = UIColor(red: CGFloat.random(in: 0..<1),
                          green: CGFloat.random(in: 0..<1),
                          blue: CGFloat.random(in: 0..<1),
                          alpha: 1)
      color.withAlphaComponent(0.5).setFill()
      color.setStroke()

      let path = UIBezierPath(rect: rect)

      ctx.cgContext.addPath(path.cgPath)
      path.fill()
      path.stroke()
      
      let labelString = NSString(string: label)
      let labelStringBounds = labelString.boundingRect(with: rect.size,
                                                       options: .usesLineFragmentOrigin,
                                                       attributes: labelAttrs,
                                                       context: nil)
      let labelStringRect = CGRect(x: rect.midX - labelStringBounds.width / 2,
                                   y: rect.minY,
                                   width: labelStringBounds.width,
                                   height: labelStringBounds.height)
      labelString.draw(in: labelStringRect, withAttributes: labelAttrs)
    }
  }
}
