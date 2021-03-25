//
//  File.swift
//  
//
//  Created by Alexey Savchenko on 24.03.2021.
//

import Foundation

public typealias DispatchFunction<Action> = (Action) -> Void
public typealias Middleware<State, Action> =
  (@escaping DispatchFunction<Action>, @escaping () -> State?)
  -> (@escaping DispatchFunction<Action>)
  -> DispatchFunction<Action>

public struct Plugin<ParentState: Hashable, LocalState: Hashable, Action> {
  
  public typealias Body = (@escaping DispatchFunction<Action>) -> (LocalState) -> Void
  public typealias Transform = (ParentState) -> LocalState
  
  public let body: Body
  public let transform: Transform
  
  public init(body: @escaping Body, transform: @escaping Transform) {
    self.body = body
    self.transform = transform
  }
}
