//
//  File.swift
//  
//
//  Created by Alexey Savchenko on 25.03.2021.
//

import Foundation
import CoreImage

public struct Pair<A, B> {
  let left: A
  let right: B

  init(left: A, right: B) {
    self.left = left
    self.right = right
  }

  init(_ tuple: (A, B)) {
    self.left = tuple.0
    self.right = tuple.1
  }
}

extension Pair where A == CIImage, B == CIImage {
  public func overlay() -> CIImage {
    return left.composited(over: right)
  }
}

public extension Pair {
  func map<C>(_ t: (A, B) -> C) -> C {
    return t(left, right)
  }

  func flatMap<C, D>(_ transform: (A, B) -> (C, D)) -> Pair<C, D> {
    return .init(transform(left, right))
  }
}

extension Pair: Equatable where A: Equatable, B: Equatable {}

extension Pair: Hashable where A: Hashable, B: Hashable {}

extension Pair: Codable where A: Codable, B: Codable {}

public struct Three<A, B, C> {
  public let a: A
  public let b: B
  public let c: C
  
  public init(a: A, b: B, c: C) {
    self.a = a
    self.b = b
    self.c = c
  }
}

extension Three: Equatable where A: Equatable, B: Equatable, C: Equatable {}

extension Three: Hashable where A: Hashable, B: Hashable, C: Hashable {}
