//
//   Optional+Extensions.swift
//  App
//
//  Created by Vadim Yakovliev on 30.03.2020.
//  Copyright © 2020 Vadym Yakovlev. All rights reserved.
//

import Foundation

extension Optional {
  func mapNil(_ f: () -> Wrapped) -> Wrapped? {
    switch self {
    case .none:
      return f()
    default:
      return self
    }
  }
  
  func flatMapNil(_ f: () -> Wrapped?) -> Wrapped? {
    switch self {
    case .none:
      return f()
    default:
      return self
    }
  }
  
  var isNotNil: Bool { !isNil }
  
  var isNil: Bool {
    switch self {
      case .none: return true
      case .some: return false
    }
  }
  
  func `as`<T>(
    _ type: T.Type
  ) -> T? { self as? T }
  
  func or(
    _ defaultValue: @autoclosure () -> Wrapped
  ) -> Wrapped {
    self ?? defaultValue()
  }
  
  @discardableResult
   func `do`(_ f: (Wrapped) -> Void) -> Optional<Wrapped> {
     return flatMap { (value) in
       f(value)
       return self
     }
   }

	@discardableResult
   func `do`(_ f: (Wrapped) -> Void, _ rollback: (() -> Void)? = nil) -> Optional<Wrapped> {
     if let _ = Optional.prism.tryGet(self) {
       return flatMap { (value) in
         f(value)
         return self
       }
     } else {
       rollback?()
       return self
     }
   }
}

extension Optional {
  static var prism: Prism<Optional, Wrapped> {
    return Prism<Optional, Wrapped>.init(
      tryGet: { $0 },
      inject: Optional.some)
  }
}

