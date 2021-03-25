//
//  File.swift
//  
//
//  Created by Alexey Savchenko on 25.03.2021.
//

import Foundation

public extension FloatingPoint {
  /// Transforms value within `sourceScale` to the value within `targetScaleScale`
  /// For example, `sourceScale` is (0...1), `targetScale` is (0...20), source value is 0.2, then returned value will be 4
  func transform(
    sourceScale: ClosedRange<Self>,
    targetScale: ClosedRange<Self>
  ) -> Self {
    let a: Self = targetScale.lowerBound + (self - sourceScale.lowerBound)
    let b: Self = targetScale.upperBound - targetScale.lowerBound
    let c: Self = sourceScale.upperBound - sourceScale.lowerBound

    return a * b / c
  }

  /// Transforms value within `sourceScale` to the value within `targetScaleScale`.
  /// For example, `sourceScale` is (0...1), `targetScale` is (0...20), source value is 0.2, then returned value will be 4
  func transform(
    sourceScale: ClosedRange<Self>,
    targetScale: ClosedRange<Int>
  ) -> Int {
    let a: Self = Self(targetScale.lowerBound) + (self - sourceScale.lowerBound)
    let b: Self = Self(targetScale.upperBound - targetScale.lowerBound)
    let c: Self = sourceScale.upperBound - sourceScale.lowerBound

    return Int((a * b / c) as! Double)
  }

  /// Radian value
  var radians: Self {
    return self * .pi / 180
  }

  func rounded2(toPlaces places: Int) -> Self {
    guard places >= 0 else { return self }
    let divisor = Self(Int(pow(10.0, Double(places))))
    return (self * divisor).rounded() / divisor
  }

  func rounded(toDividingEvenlyTo divisor: Self) -> Self {
    var result = self.rounded(.toNearestOrEven)
    while result.truncatingRemainder(dividingBy: divisor) != 0 {
      result += 1
    }
    return result
  }

  /// Clamps value to `min` and `max`
  func clamped(min: Self, max: Self) -> Self {
    if self < min {
      return min
    } else if self > max {
      return max
    } else {
      return self
    }
  }
}
