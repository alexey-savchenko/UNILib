//
//  File.swift
//  
//
//  Created by Alexey Savchenko on 30.03.2021.
//

import CoreGraphics

public extension CGAffineTransform {
  /// Convenience function to easily get a scale `CGAffineTransform` instance.
  ///
  /// - Parameters:
  ///   - fromSize: The size that needs to be transformed to fit (aspect fill) in the other given size.
  ///   - toSize: The size that should be matched by the `fromSize` parameter.
  /// - Returns: The transform that will make the `fromSize` parameter fir (aspect fill) inside the `toSize` parameter.
  static func scaleTransform(
    forSize fromSize: CGSize,
    aspectFillInSize toSize: CGSize
  ) -> CGAffineTransform {
    let scale = max(
      toSize.width / fromSize.width,
      toSize.height / fromSize.height
    )
    return CGAffineTransform(
      scaleX: scale,
      y: scale
    )
  }

  /// Convenience function to easily get a translate `CGAffineTransform` instance.
  ///
  /// - Parameters:
  ///   - fromRect: The rect which center needs to be translated to the center of the other passed in rect.
  ///   - toRect: The rect that should be matched.
  /// - Returns: The transform that will translate the center of the `fromRect` parameter to the center of the `toRect` parameter.
  static func translateTransform(
    fromCenterOfRect fromRect: CGRect,
    toCenterOfRect toRect: CGRect
  ) -> CGAffineTransform {
    let translate = CGPoint(
      x: toRect.midX - fromRect.midX,
      y: toRect.midY - fromRect.midY
    )
    return CGAffineTransform(
      translationX: translate.x,
      y: translate.y
    )
  }
  
  var xScale: CGFloat { sqrt(a * a + c * c) }
  var yScale: CGFloat { sqrt(b * b + d * d) }
  var rotation: CGFloat { CGFloat(atan2(Double(b), Double(a))) }
  var xOffset: CGFloat { tx }
  var yOffset: CGFloat { ty }
}

extension CGAffineTransform: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.a)
    hasher.combine(self.b)
    hasher.combine(self.c)
    hasher.combine(self.d)
    hasher.combine(self.tx)
    hasher.combine(self.ty)
  }
}
