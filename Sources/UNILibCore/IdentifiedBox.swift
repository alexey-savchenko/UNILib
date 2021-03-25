//
//  File.swift
//  
//
//  Created by Alexey Savchenko on 25.03.2021.
//

import Foundation

public class IdentifiedBox<T>: Identifiable {
  public let value: T
  public let id = UUID()

  public init(_ value: T) {
    self.value = value
  }
}

extension IdentifiedBox: Equatable where T: Equatable {
  public static func == (lhs: IdentifiedBox<T>, rhs: IdentifiedBox<T>) -> Bool {
    return lhs.value == rhs.value && lhs.id == rhs.id
  }
}

extension IdentifiedBox: Hashable where T: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(value)
    hasher.combine(id)
  }
}
