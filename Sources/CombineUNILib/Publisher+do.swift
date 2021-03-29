//
//  File.swift
//  
//
//  Created by Alexey Savchenko on 13.03.2021.
//

import Combine

@available(iOS 13.0, *)
public extension Publisher {
  func `do`(_ action: @escaping (Self.Output) -> Void) -> AnyPublisher<Self.Output, Self.Failure> {
    return handleEvents(receiveOutput: { value in
      action(value)
    })
    .eraseToAnyPublisher()
  }
}
