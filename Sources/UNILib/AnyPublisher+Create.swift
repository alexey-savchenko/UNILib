//
//  File 2.swift
//  
//
//  Created by Alexey Savchenko on 13.03.2021.
//

import Combine

public struct AnyObserver<Output, Failure: Error> {
  let onNext: ((Output) -> Void)
  let onError: ((Failure) -> Void)
  let onComplete: (() -> Void)
}

public struct Disposable {
  let dispose: () -> Void
  
  static let create = Disposable(dispose: {})
}

public extension AnyPublisher {
  static func create(subscribe: @escaping (AnyObserver<Output, Failure>) -> Disposable) -> Self {
    let subject = PassthroughSubject<Output, Failure>()
    var disposable: Disposable?
    return subject
      .handleEvents(receiveSubscription: { subscription in
        disposable = subscribe(AnyObserver(
          onNext: { output in subject.send(output) },
          onError: { failure in subject.send(completion: .failure(failure)) },
          onComplete: { subject.send(completion: .finished) }
        ))
      }, receiveCancel: { disposable?.dispose() })
      .eraseToAnyPublisher()
  }
}
