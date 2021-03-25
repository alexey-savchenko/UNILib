//
//  File.swift
//  
//
//  Created by Alexey Savchenko on 23.03.2021.
//

import Foundation
import RxSwift
import RxCocoa
import UNILibCore

public typealias RxIndependentPlugin<State: Hashable, Action> = (RxStore<State, Action>?) -> Disposable?

public final class RxStore<State: Hashable, Action> {
  private let reducer: Reducer<State, Action>
  public let disposeBag = DisposeBag()
  private let state: BehaviorRelay<State>
  private lazy var dispatchFunction: DispatchFunction<Action> = createDispatchFunction()
  private let reduceQueue = DispatchQueue(
    label: "Reduce_queue",
    qos: .background,
    autoreleaseFrequency: .workItem
  )
  public var middleware: [Middleware<State, Action>] = [] {
    didSet {
      dispatchFunction = createDispatchFunction()
    }
  }

  public var stateObservable: Observable<State> {
    return state.asObservable().observeOn(MainScheduler.instance)
  }

  public init(
    inputState: State,
    middleware: [Middleware<State, Action>],
    reducer: Reducer<State, Action>
  ) {
    self.middleware = middleware
    self.state = .init(value: inputState)
    self.reducer = reducer
  }

  deinit {
    print("\(self) dealloc")
  }

  public func attach(_ plugin: RxIndependentPlugin<State, Action>) {
    weak var weakSelf = self
    plugin(weakSelf)?.disposed(by: disposeBag)
  }

  public func attach<T>(_ plugin: Plugin<State, T, Action>) {
    stateObservable
      .map(plugin.transform)
      .distinctUntilChanged()
      .observeOn(SerialDispatchQueueScheduler(qos: .background))
      .subscribe(onNext: plugin.body(dispatch))
      .disposed(by: disposeBag)
  }

  public func dispatch(_ action: Action) {
    print("Dispatch at \(time()) - " + String(describing: action).prefix(1000))
    dispatchFunction(action)
  }

  private func createDispatchFunction() -> DispatchFunction<Action> {
    middleware
      .reversed()
      .reduce({ [unowned self] action in
        self.reduce(action)
      }) { (dispatchFunction, middleware) -> DispatchFunction<Action> in
        let dispatch: (Action) -> Void = { [weak self] in self?.dispatch($0) }
        let getState = { [weak self] in self?.state.value }
        return middleware(dispatch, getState)(dispatchFunction)
      }
  }

  private func reduce(_ action: Action) {
    reduceQueue.sync {
      let currentState = self.state.value
      let newState = reducer.reduce(currentState, action)
      self.state.accept(newState)
    }
  }
}

public extension RxStore {
  func dispatch(_ actions: [Action]) {
    actions.forEach(dispatch)
  }
}
