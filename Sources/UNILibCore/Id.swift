//
//  File.swift
//  
//
//  Created by Alexey Savchenko on 16.12.2020.
//

import Foundation

public struct Id<E>: Hashable, ExpressibleByStringLiteral {
  public let raw: String
  
  public init(stringLiteral value: String) {
    self.raw = value
  }
}
