//
//  File.swift
//  
//
//  Created by Alexey Savchenko on 25.03.2021.
//

import Foundation

public class Wrapped<T> {
  public let value: T

  public init(_ value: T) {
    self.value = value
  }
}

public struct _Void: Hashable, Equatable, Codable {}

public extension _Void {
  init(_ any: Any = Void()) {}
}

extension _Void: RawRepresentable {
  public var rawValue: Int {
    return .zero
  }

  public init?(rawValue: Int) {}
}

extension Wrapped: Equatable where T: Equatable {
  public static func == (lhs: Wrapped<T>, rhs: Wrapped<T>) -> Bool {
    return lhs.value == rhs.value
  }
}

extension Wrapped: Hashable where T: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(value)
  }
}
