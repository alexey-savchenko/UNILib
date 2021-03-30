//
//  File.swift
//  
//
//  Created by Alexey Savchenko on 25.03.2021.
//

import CoreGraphics

public extension CGRect {
  var middle: CGPoint {
    return CGPoint(x: midX, y: midY)
  }

  func translated(by point: CGPoint) -> CGRect {
    return CGRect(x: origin.x + point.x, y: origin.y + point.y, width: width, height: height)
  }

  func scaled(by value: CGPoint) -> CGRect {
    return CGRect(x: origin.x, y: origin.y, width: width + value.x, height: height + value.y)
  }

  func scaledCentered(by scale: CGFloat) -> CGRect {
    //    guard scale != 1 else { return self }

    let insetX = scale > 1 ? -(width * (1 - scale)) : width * scale
    let insetY = scale > 1 ? -(height * (1 - scale)) : height * scale

    return insetBy(dx: insetX, dy: insetY)
  }

  static func bounding(_ rects: [CGRect]) -> CGRect {
    if let f = rects.first {
      let _f = f
      return rects.reduce(into: _f) { result, rect in
        result = result.union(rect)
      }
    } else {
      return rects.reduce(into: CGRect.zero) { result, rect in
        result = result.union(rect)
      }
    }
  }

  static func squareWithCenter(_ centerPoint: CGPoint, size: CGFloat) -> CGRect {
    return CGRect(x: centerPoint.x - size / 2, y: centerPoint.y - size / 2, width: size, height: size)
  }
  
  /// Returns a new `CGRect` instance scaled up or down, with the same center as the original `CGRect` instance.
  /// - Parameters:
  ///   - ratio: The ratio to scale the `CGRect` instance by.
  /// - Returns: A new instance of `CGRect` scaled by the given ratio and centered with the original rect.
  func scaleAndCenter(withRatio ratio: CGFloat) -> CGRect {
      let scaleTransform = CGAffineTransform(scaleX: ratio, y: ratio)
      let scaledRect = applying(scaleTransform)
      
      let translateTransform = CGAffineTransform(translationX: origin.x * (1 - ratio) + (width - scaledRect.width) / 2.0, y: origin.y * (1 - ratio) + (height - scaledRect.height) / 2.0)
      let translatedRect = scaledRect.applying(translateTransform)
      
      return translatedRect
  }

}
