//
//  FreeFunctions.swift
//  Scanner
//
//  Created by Vadym Yakovlev on 29.01.2020.
//  Copyright © 2020 Vadym Yakovlev. All rights reserved.
//

import CoreImage
import Foundation

// MARK: - Auxiliary functions

public func compactMap<T>(_ input: [T?]) -> [T] {
  return input.compactMap(identity)
}

public func benchmark(operationTitle: String? = nil, operation: () -> Void) {
  let startTime = CFAbsoluteTimeGetCurrent()
  operation()
  let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
  print("Time elapsed for \(operationTitle ?? "unknown"): \(timeElapsed) s.")
}

public func notNil<E>(_ input: E?) -> Bool {
  return input.isNotNil
}

public func isNil<E>(_ input: E?) -> Bool {
  return input.isNil
}

public func toVoid(_ value: Any) -> Void {
  return Void()
}

public func breakpoint(_ value: Any) {
  print("breapoint")
}

public func empty(_ value: Any) {
  
}

public func identity<T>(_ item: T) -> T {
  return item
}

public func identityOp<T>(_ item: T) -> T? {
  return item
}

public func isTrue(_ input: Bool) -> Bool {
  return input == true
}

public func isFalse(_ input: Bool) -> Bool {
  return input == false
}

public func toArray<E>(_ item: E) -> [E] {
  return [item]
}

// MARK: - Expand Optional -

/// Two optionals to one optional tuple
public func zip2<A, B>(
  _ variant1: Optional<A>,
  _ variant2: Optional<B>
) -> Optional<(A, B)> {
  return variant1.flatMap { val1 in
    return variant2.flatMap { val2 in (val1, val2) }
  }
}

/// Three optionals to one optional tuple
public func zip3<A, B, C>(
  _ variant1: Optional<A>,
  _ variant2: Optional<B>,
  _ variant3: Optional<C>
) -> Optional<(A, B, C)> {
  return variant1.flatMap { val1 in
    return variant2.flatMap { val2 in
      return variant3.flatMap { val3 in (val1, val2, val3) }
    }
  }
}

public func onMainQueue(_ block: @escaping () -> Void) {
  DispatchQueue.main.async(execute: block)
}

public func onGlobalUtilityQueue(_ block: @escaping () -> Void) {
  DispatchQueue.global(qos: .utility).async(execute: block)
}

// MARK: - Preprocessor Macros Wrappers -

/// Execute in a specific build configuration
public func executeOn<T>(debug: () -> T, release: () -> T) -> T {
  #if DEBUG
  return debug()
  #else
  return release()
  #endif
}

/// Execute in a specific build configuration
public func executeOn(debug: (() -> Void)? = nil, release: (() -> Void)? = nil) {
  executeOn(debug: debug ?? {}, release: release ?? {})
}

/// Execute on simulator or real device
public func executeOn<T>(simulator: () -> T, device: () -> T) -> T {
  #if targetEnvironment(simulator)
  return simulator()
  #else
  return device()
  #endif
}

/// Execute on simulator or real device
public func executeOn(simulator: (() -> Void)? = nil, device: (() -> Void)? = nil) {
  executeOn(simulator: simulator ?? {}, device: device ?? {})
}

public func * (lhs: CGPoint, rhs: CGSize) -> CGPoint {
  return .init(x: lhs.x * rhs.width, y: lhs.y * rhs.height)
}

public func resample<T>(array: [T], toSize newSize: Int) -> [T] {
  guard !array.isEmpty else { return [] }
  let size = array.count
  return (0 ..< newSize).map { array[$0 * size / newSize] }
}

public func ifNaN<T: FloatingPoint>(_ value: T, fallback: T) -> T {
  if value.isNaN {
    return fallback
  } else {
    return value
  }
}

// MARK: - Policy Attributed Text

public func recursively<T>(
  operation: (T) -> Void,
  on target: T,
  children: (T) -> [T]
) {
  
  operation(target)
  children(target)
    .forEach { child in
      recursively(
        operation: operation,
        on: child,
        children: children
      )
    }
}

public func time() -> String {
  let f = DateFormatter()
  f.dateFormat = "HH:mm:ss.SSS"
  return f.string(from: Date())
}
