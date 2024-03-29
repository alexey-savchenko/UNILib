//
//  File.swift
//  
//
//  Created by Alexey Savchenko on 27.02.2021.
//

import Foundation


// sourcery: Prism
public enum Either<A, B> {
  case left(value: A)
  case right(value: B)
}

public extension Either {
  var isRight: Bool {
    switch self {
    case .right:
      return true
    default:
      return false
    }
  }

  var isLeft: Bool {
    switch self {
    case .left:
      return true
    default:
      return false
    }
  }

  var left: A? {
    switch self {
    case let .left(left):
      return left
    case .right:
      return nil
    }
  }

  var right: B? {
    switch self {
    case .left:
      return nil
    case let .right(right):
      return right
    }
  }
}

extension Either: CustomDebugStringConvertible where A: CustomDebugStringConvertible, B: CustomDebugStringConvertible {
  public var debugDescription: String {
    switch self {
    case .left(let value):
      return value.debugDescription
    case .right(let value):
      return value.debugDescription
    }
  }
}

// sourcery: prism
public enum Loadable<T, Error: Hashable> {
  case item(item: T)
  case loading(progress: Float)
  case empty
  case error(error: Error)

  public static var indefiniteLoading: Loadable<T, Error> {
    return .loading(progress: 0)
  }
}

extension Loadable: Equatable where T: Equatable {
	
}

extension Loadable: Hashable where T: Hashable {
	
}

public extension Loadable {
  func map<U>(_ transform: (T) -> U) -> Loadable<U, Error> {
    switch self {
    case .empty: return .empty
    case .error(let error): return .error(error: error)
    case .item(let item): return Loadable<U, Error>.item(item: transform(item))
    case .loading(let progress): return .loading(progress: progress)
    }
  }

  func flatMap<U>(_ transform: (T) -> Loadable<U, Error>) -> Loadable<U, Error> {
    switch self {
    case .empty: return .empty
    case .error(let error): return .error(error: error)
    case .item(let item): return transform(item)
    case .loading(let progress): return .loading(progress: progress)
    }
  }

	static func aggregatingProgressIgnoringErrors<V>(_ loadables: [Loadable<V, Error>]) -> Loadable<[V], Error> {
    let realExporting: [Float] = loadables
      .compactMap { value in
        switch value {
        case .loading(let progress):
          return progress
        default:
          return nil
        }
      }
    
    if realExporting.count > 0 {
      let preudoExporting: [Float] = loadables
        .map { loadable -> Loadable<V, Error> in
          switch loadable {
          case .loading:
            return loadable
          case .item:
            return Loadable<V, Error>.loading(progress: 1)
          default:
            return Loadable<V, Error>.indefiniteLoading
          }
        }
        .compactMap { value in
          switch value {
          case .loading(let progress):
            return progress
          default:
            return nil
          }
        }

      let overallProgress = preudoExporting.reduce(0.0) { acc, elem in
        acc + elem / Float(preudoExporting.count)
      }
      return .loading(progress: overallProgress)
    } else {
      let complete: [V] = loadables
        .compactMap { value in
          switch value {
          case .item(let item):
            return item
          default:
            return nil
          }
        }
      
      return .item(item: complete)
    }
  }
}
