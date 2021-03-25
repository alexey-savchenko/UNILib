//
//  File.swift
//  
//
//  Created by Alexey Savchenko on 25.03.2021.
//

import Foundation

public class HashableWrapper<T>: Hashable, Identifiable {
  public let value: T
  public let id = UUID()

  public init(value: T) {
    self.value = value
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  public static func == (lhs: HashableWrapper<T>, rhs: HashableWrapper<T>) -> Bool {
    return lhs.id == rhs.id
  }
}
