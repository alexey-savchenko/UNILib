import Foundation

@Observable
public final class Store<State: Equatable & Sendable, Action: Sendable> {
    private(set) var _state: State
    let reducer: Reducer<State, Action>
    private let queue = DispatchQueue(
        label: "store.queue",
        qos: .userInitiated,
        attributes: .concurrent
    )
    
    public var state: State {
        get {
            queue.sync { _state }
        }
        set {
            queue.async(flags: .barrier) { [weak self] in
                self?.updateState(newValue)
            }
        }
    }
    
    public init(initialState: State, reducer: Reducer<State, Action>) {
        self._state = initialState
        self.reducer = reducer
    }
    
    private func updateState(_ newState: State) {
        _state = newState
    }
    
    public func send(_ action: Action) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self else { return }
            
            let oldState = self._state
            self.reducer.reduce(&self._state, action, self.send)
            
            // Notify observers on main queue if state changed
            if oldState != self._state {
                DispatchQueue.main.async {
                    // This triggers @Observable notifications
                    self.state = self._state
                }
            }
        }
    }
}

extension Store: @unchecked Sendable {}
