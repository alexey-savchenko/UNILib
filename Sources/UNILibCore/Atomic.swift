//
//  File.swift
//  
//
//  Created by Alexey Savchenko on 25.03.2021.
//

import Foundation

public class Atomic<V> {
  
  public let id = UUID()
  public lazy var syncQueue: DispatchQueue = {
    return DispatchQueue(label: "syncQueue_\(id.uuidString)", attributes: .concurrent)
  }()

  private var _value: V
  public var value: V {
    get {
      return syncQueue.sync {
        return _value
      }
    }
    set(newValue) {
      syncQueue.async(flags: .barrier) {
        self._value = newValue
      }
    }
  }

  public init(value: V) {
    self._value = value
  }
}
