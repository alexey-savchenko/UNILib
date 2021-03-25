//
//  File.swift
//  
//
//  Created by Alexey Savchenko on 23.03.2021.
//

import Foundation

public protocol Occupiable {
  var isEmpty: Bool { get }
  var isNotEmpty: Bool { get }
}

public extension Occupiable {
  var isNotEmpty: Bool {
    return !isEmpty
  }
}

extension String: Occupiable {}
// I can't think of a way to combine these collection types. Suggestions welcomed!
extension Array: Occupiable {}
extension Dictionary: Occupiable {}
extension Set: Occupiable {}

public extension ClosedRange where Bound: FloatingPointMath {
  var middle: Bound {
    return lowerBound + (upperBound - lowerBound) / Bound(2.0)
  }
}

public extension ClosedRange where Bound == Int {
  var middle: Bound {
    return lowerBound + (upperBound - lowerBound) / 2
  }
}

public extension Collection {
  /// Returns the element at the specified index if it is within bounds, otherwise nil.
  subscript(safe index: Index) -> Element? {
    return indices
      .contains(index) ? self[index] : nil
  }
}

public extension Set {
  func updated(with value: Element) -> Set<Element> {
    var copy = self
    copy.update(with: value)
    return copy
  }
}

public extension Dictionary {
  subscript<T: RawRepresentable>(value: T) -> Value? where T.RawValue == String {
    return self[value.rawValue as! Key]
  }
}
