import Foundation

public struct Reducer<State, Action> {
    let reduce: (inout State, Action, @escaping (Action) -> Void) -> Void
    
    public init(
        reduce: @escaping (inout State, Action, @escaping (Action) -> Void) -> Void
    ) {
        self.reduce = reduce
    }
}
