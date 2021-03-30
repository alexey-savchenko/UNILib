//
//  File.swift
//  
//
//  Created by Alexey Savchenko on 30.03.2021.
//

import CoreImage
import CoreGraphics

precedencegroup CompositionPrecedence {
  associativity: right
  higherThan: ApplicationPrecedence, AssignmentPrecedence
}

precedencegroup ApplicationPrecedence {
  associativity: left
}

infix operator |>: ApplicationPrecedence

public func |> <I, O>(lhs: I, rhs: (I) -> O) -> O {
  return rhs(lhs)
}

public func |> <I, O>(lhs: I?, rhs: (I) -> O?) -> O? {
  return lhs.flatMap(rhs)
}

public func |> <I, O>(lhs: I, rhs: (I) -> O?) -> O? {
  return rhs(lhs)
}

/// Functional composition
///
public func map<I, O, O2>(
  lhs: @escaping (I) -> O,
  rhs: @escaping (O) -> O2
) -> (I) -> O2 {
  return { input in
    return rhs(lhs(input))
  }
}

public func map<I, O, O2>(
  lhs: @escaping (I) -> O?,
  rhs: @escaping (O) -> O2?
) -> (I) -> O2? {
  return { input in
    return lhs(input).flatMap(rhs)
  }
}

infix operator <*>: CompositionPrecedence
public func <*><I, O, O2> (
  lhs: @escaping (I) -> O,
  rhs: @escaping (O) -> O2
) -> (I) -> O2 {
  return map(lhs: lhs, rhs: rhs)
}

public func <*><I, O, O2> (
  lhs: @escaping (I) -> O?,
  rhs: @escaping (O) -> O2?
) -> (I) -> O2? {
  return map(lhs: lhs, rhs: rhs)
}

infix operator <>: CompositionPrecedence
public func <> <Whole, A, B> (
  lhs: Lens<Whole, A>,
  rhs: Lens<Whole, B>
) -> Lens<Whole, (A, B)> {
  return Lens<Whole, (A, B)>(
    get: { whole in return (lhs.get(whole), rhs.get(whole)) },
    set: { (arg0: (A, B)) -> (Whole) -> Whole in
      let (a, b) = arg0
      return { (whole: Whole) -> Whole in
        return lhs.set(a)(rhs.set(b)(whole))
      }
    })
}

infix operator >>>: ApplicationPrecedence
public func >>> (lhs: CIImage, rhs: PositionParams) -> CIImage {
  let transform =
    CGAffineTransform.identity
      .concatenating(.init(scaleX: rhs.0.width, y: rhs.0.height))
      .concatenating(.init(translationX: rhs.1.x, y: rhs.1.y))
  return lhs.transformed(by: transform)
}
