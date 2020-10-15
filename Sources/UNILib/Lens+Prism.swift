//
//  Lens+Prism.swift
//  Scanner
//
//  Created by Vadym Yakovlev on 29.01.2020.
//  Copyright © 2020 Vadym Yakovlev. All rights reserved.
//

import Foundation

struct Lens<Whole, Part> {
  let get: (Whole) -> Part
  let set: (Part) -> (Whole) -> Whole
}

struct Prism<Whole, Part> {
  let tryGet: (Whole) -> Part?
  let inject: (Part) -> Whole
}

struct Affine<Whole, Part> {
  let tryGet: (Whole) -> Part?
  let trySet: (Part) -> (Whole) -> Whole?
}

extension Affine {
  func then <Subpart> (
    _ other: Affine<Part, Subpart>
  ) -> Affine<Whole, Subpart> {
    
    return Affine<Whole,Subpart>.init(
      tryGet: { s in self.tryGet(s).flatMap(other.tryGet) },
      trySet: { bp in
        { s in
          self.tryGet(s)
            .flatMap { a in other.trySet(bp)(a) }
            .flatMap { b in self.trySet(b)(s) }
        }
    })
  }
}

extension Lens {
  func toAffine() -> Affine<Whole, Part> {
    return Affine<Whole,Part>.init(
      tryGet: self.get,
      trySet: self.set)
  }
  
  func lift<Composite>(_ l: Lens<Composite, Whole>) -> Lens<Composite, Part> {
    return Lens<Composite, Part>(
      get: { (composite) -> Part in
        return self.get(l.get(composite)) },
      set: { (subSubPart) -> (Composite) -> Composite in
        return { composite in
          let subPart = self.set(subSubPart)(l.get(composite))
          return l.set(subPart)(composite)
        }
    })
  }
}
