//
//  File.swift
//  
//
//  Created by Alexey Savchenko on 23.03.2021.
//

import Foundation
import RxSwift

public protocol OptionalType {
  associatedtype Wrapped
  var value: Wrapped? { get }
}

extension Optional: OptionalType {
  /// Cast `Optional<Wrapped>` to `Wrapped?`
  public var value: Wrapped? {
    return self
  }
}

extension ObservableType where Element: OptionalType {
  func filterNil() -> Observable<Element.Wrapped> {
    return flatMap { element -> Observable<Element.Wrapped> in
      guard let value = element.value else {
        return Observable<Element.Wrapped>.empty()
      }
      return Observable<Element.Wrapped>.just(value)
    }
  }
}
