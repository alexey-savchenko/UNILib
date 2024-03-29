//
//  File.swift
//  
//
//  Created by Alexey Savchenko on 25.03.2021.
//

import CoreGraphics

public extension CGPoint {
  func square(_ side: CGFloat) -> CGRect {
    return CGRect(
      x: x - side / 2,
      y: y - side / 2,
      width: side,
      height: side
    )
  }

  static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
  }

  static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
  }

  static func / (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    return CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
  }

  static func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
  }

  static func - (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    return CGPoint(x: lhs.x - rhs, y: lhs.y - rhs)
  }

  static func + (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    return CGPoint(x: lhs.x + rhs, y: lhs.y + rhs)
  }
  
  /// Returns a rectangle of a given size surounding the point.
  ///
  /// - Parameters:
  ///   - size: The size of the rectangle that should surround the points.
  /// - Returns: A `CGRect` instance that surrounds this instance of `CGpoint`.
  func surroundingSquare(withSize size: CGFloat) -> CGRect {
      return CGRect(x: x - size / 2.0, y: y - size / 2.0, width: size, height: size)
  }
  
  /// Checks wether this point is within a given distance of another point.
  ///
  /// - Parameters:
  ///   - delta: The minimum distance to meet for this distance to return true.
  ///   - point: The second point to compare this instance with.
  /// - Returns: True if the given `CGPoint` is within the given distance of this instance of `CGPoint`.
  func isWithin(delta: CGFloat, ofPoint point: CGPoint) -> Bool {
      return (abs(x - point.x) <= delta) && (abs(y - point.y) <= delta)
  }
  
  /// Returns the same `CGPoint` in the cartesian coordinate system.
  ///
  /// - Parameters:
  ///   - height: The height of the bounds this points belong to, in the current coordinate system.
  /// - Returns: The same point in the cartesian coordinate system.
  func cartesian(withHeight height: CGFloat) -> CGPoint {
      return CGPoint(x: x, y: height - y)
  }
  
  /// Returns the distance between two points
  func distanceTo(point: CGPoint) -> CGFloat {
      return hypot((self.x - point.x), (self.y - point.y))
  }
}
