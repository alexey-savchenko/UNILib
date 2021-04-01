//
//  File.swift
//  
//
//  Created by Alexey Savchenko on 01.04.2021.
//

import Foundation
import RxSwift

typealias PreviousCurrentPair<E> = (previous: E?, current: E)

extension ObservableType {
  func withPrevious() -> Observable<PreviousCurrentPair<Element>> {
    return scan([], accumulator: { previous, current in
      Array(previous + [current]).suffix(2)
    })
      .map({ arr -> (previous: Element?, current: Element) in
        (arr.count > 1 ? arr.first : nil, arr.last!)
      })
  }

  static func zipIfNotEmpty<C>(
    _ collection: C
  ) -> RxSwift.Observable<[Self.Element]>
    where C: Collection, Self.Element == C.Element.Element, C.Element: RxSwift.ObservableType {
    if collection.isEmpty {
      return .just([])
    } else {
      return Self.zip(collection)
    }
  }
}
