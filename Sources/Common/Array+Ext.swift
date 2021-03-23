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
