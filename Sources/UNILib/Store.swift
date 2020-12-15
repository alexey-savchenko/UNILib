
import Foundation
import Combine

typealias DispatchFunction<Action> = (Action) -> Void
typealias Middleware<State, Action> =
  (@escaping DispatchFunction<Action>, @escaping () -> State?)
  -> (@escaping DispatchFunction<Action>)
  -> DispatchFunction<Action>

struct Plugin<ParentState: Hashable, LocalState: Hashable, Action> {
  
  typealias Body = (@escaping DispatchFunction<Action>) -> (LocalState) -> Void
  typealias Transform = (ParentState) -> LocalState
  
  let body: Body
  let transform: Transform
}

typealias IndependentPlugin<State: Hashable, Action> = (Store<State, Action>?) -> AnyCancellable?

final class Store<State: Hashable, Action> {

  private let reducer: Reducer<State, Action>
  private var disposeBag = Set<AnyCancellable>()
  private let state: CurrentValueSubject<State, Never>
  private lazy var dispatchFunction: DispatchFunction<Action> = createDispatchFunction()
  private let reduceQueue = DispatchQueue(label: "Reduce_queue",
                                          qos: .background,
                                          autoreleaseFrequency: .workItem)
  var middleware: [Middleware<State, Action>] = [] {
    didSet {
      dispatchFunction = createDispatchFunction()
    }
  }
  
  var stateObservable: AnyPublisher<State, Never> {
    return state.eraseToAnyPublisher()
  }
  
  init(inputState: State,
       middleware: [Middleware<State, Action>],
       reducer: Reducer<State, Action>) {
    self.middleware = middleware
    self.state = .init(inputState)
    self.reducer = reducer
  }
  
  deinit {
    print("\(self) dealloc")
  }
  
  func attach(_ plugin: IndependentPlugin<State, Action>) {
    weak var weakSelf = self
    plugin(weakSelf)?.store(in: &disposeBag)
  }
  
  func attach<T>(_ plugin: Plugin<State, T, Action>) {
    stateObservable
      .map(plugin.transform)
      .removeDuplicates()
      .receive(on: DispatchQueue.global(qos: .background))
      .sink(receiveValue: plugin.body(dispatch))
      .store(in: &disposeBag)
  }
  
  func dispatch(_ action: Action) {
    dispatchFunction(action)
  }
  
  private func createDispatchFunction() -> DispatchFunction<Action> {
    middleware
      .reversed()
      .reduce({ [unowned self] action in
        return self.reduce(action)
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
      self.state.send(newState)
    }
  }
}

extension Store {
  func dispatch(_ actions: [Action]) {
    actions.forEach(dispatch)
  }
}

