
import Foundation

precedencegroup CompositionPrecedence {
  associativity: right
  higherThan: AssignmentPrecedence
}

/// Functional composition
///
public func map<I, O, O2>(lhs: @escaping (I) -> O,
                   rhs: @escaping (O) -> O2) -> (I) -> O2 {
  return { input in
    return rhs(lhs(input))
  }
}

public func map<I, O, O2>(lhs: @escaping (I) -> O?,
                   rhs: @escaping (O) -> O2?) -> (I) -> O2? {
  return { input in
    return lhs(input).flatMap(rhs)
  }
}

infix operator <*>: CompositionPrecedence
public func <*><I, O, O2> (lhs: @escaping (I) -> O,
                   rhs: @escaping (O) -> O2) -> (I) -> O2 {
  return map(lhs: lhs, rhs: rhs)
}

public func <*><I, O, O2> (lhs: @escaping (I) -> O?,
                   rhs: @escaping (O) -> O2?) -> (I) -> O2? {
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

precedencegroup MonoidAppend {
  associativity: left
}

public protocol Monoid {
  static var empty: Self { get }
  static func <> (lhs: Self, rhs: Self) -> Self
}

public struct Reducer<State, Action> {
  public let reduce: (State, Action) -> State
  
  public init(reduce: @escaping (State, Action) -> State) {
    self.reduce = reduce
  }
}

extension Reducer: Monoid {
  public static func <> (lhs: Reducer<State, Action>,
                  rhs: Reducer<State, Action>) -> Reducer<State, Action> {
    return Reducer<State, Action>(reduce: { (s, a) in
      return rhs.reduce(lhs.reduce(s, a), a)
    })
  }
  
  public static var empty: Reducer<State, Action> {
    return Reducer { s, _ in s }
  }
}

public extension Reducer {
  func lift<GlobalState>(
    localStateLens: Lens<GlobalState, State>
  ) -> Reducer<GlobalState, Action> {
    
    return Reducer<GlobalState, Action>(
      reduce: { (globalState, action) -> GlobalState in
        let updatedLocalState = self.reduce(localStateLens.get(globalState), action)
        return localStateLens.set(updatedLocalState)(globalState)
    })
  }
  
  func lift<GlobalAction>(
    localActionPrism: Prism<GlobalAction, Action>
  ) -> Reducer<State, GlobalAction> {
    
    return Reducer<State, GlobalAction>(
      reduce: { (state, globalAction) -> State in
        if let localAction = localActionPrism.tryGet(globalAction) {
          return self.reduce(state, localAction)
        } else {
          return state
        }
    })
  }
  
  func lift<GlobalState, GlobalAction>(
    localStateLens: Lens<GlobalState, State>,
    localActionPrism: Prism<GlobalAction, Action>
  ) -> Reducer<GlobalState, GlobalAction> {
    
    return Reducer<GlobalState, GlobalAction>(
      reduce: { (globalState, globalAction) -> GlobalState in
        
        if let localAction = localActionPrism.tryGet(globalAction) {
          let updatedState = self.reduce(localStateLens.get(globalState), localAction)
          return localStateLens.set(updatedState)(globalState)
        } else {
          return globalState
        }
    })
  }
}

