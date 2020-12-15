
import Foundation
import Combine

public typealias DispatchFunction<Action> = (Action) -> Void
public typealias Middleware<State, Action> =
  (@escaping DispatchFunction<Action>, @escaping () -> State?)
  -> (@escaping DispatchFunction<Action>)
  -> DispatchFunction<Action>

public struct Plugin<ParentState: Hashable, LocalState: Hashable, Action> {
  
  typealias Body = (@escaping DispatchFunction<Action>) -> (LocalState) -> Void
  typealias Transform = (ParentState) -> LocalState
  
  let body: Body
  let transform: Transform
}

public typealias IndependentPlugin<State: Hashable, Action> = (Store<State, Action>?) -> AnyCancellable?

public final class Store<State: Hashable, Action>: ObservableObject {
  
  private let reducer: Reducer<State, Action>
  private var disposeBag = Set<AnyCancellable>()
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
  
  @Published public private(set) var state: State
    
  public init(
    inputState: State,
    middleware: [Middleware<State, Action>],
    reducer: Reducer<State, Action>
  ) {
    self.middleware = middleware
    self.reducer = reducer
    self.state = inputState
  }
  
  deinit {
    print("\(self) dealloc")
  }
  
  public func attach(_ plugin: IndependentPlugin<State, Action>) {
    weak var weakSelf = self
    plugin(weakSelf)?.store(in: &disposeBag)
  }
  
  public func attach<T>(_ plugin: Plugin<State, T, Action>) {
    $state
      .map(plugin.transform)
      .removeDuplicates()
      .receive(on: DispatchQueue.global(qos: .background))
      .sink(receiveValue: plugin.body(dispatch))
      .store(in: &disposeBag)
  }
  
  public func dispatch(_ action: Action) {
    dispatchFunction(action)
  }
  
  private func createDispatchFunction() -> DispatchFunction<Action> {
    middleware
      .reversed()
      .reduce({ [unowned self] action in
        return self.reduce(action)
      }) { (dispatchFunction, middleware) -> DispatchFunction<Action> in
        let dispatch: (Action) -> Void = { [weak self] in self?.dispatch($0) }
        let getState = { [weak self] in self?.state }
        return middleware(dispatch, getState)(dispatchFunction)
      }
  }
  
  private func reduce(_ action: Action) {
    reduceQueue.sync {
      let currentState = self.state
      let newState = reducer.reduce(currentState, action)
      self.state = newState
    }
  }
}

public extension Store {
  func dispatch(_ actions: [Action]) {
    actions.forEach(dispatch)
  }
}
