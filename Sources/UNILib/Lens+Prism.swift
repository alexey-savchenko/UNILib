//
//  Lens+Prism.swift
//  Scanner
//
//  Created by Vadym Yakovlev on 29.01.2020.
//  Copyright © 2020 Vadym Yakovlev. All rights reserved.
//

import Foundation

public struct Lens<Whole, Part> {
  let get: (Whole) -> Part
  let set: (Part) -> (Whole) -> Whole
}

public struct Prism<Whole, Part> {
  let tryGet: (Whole) -> Part?
  let inject: (Part) -> Whole
}

public struct Affine<Whole, Part> {
  let tryGet: (Whole) -> Part?
  let trySet: (Part) -> (Whole) -> Whole?
}

public extension Affine {
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

public extension Lens {
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

/*
 
 Sourcery templates
 
 -- LENS
 
 {% for type in types.structs|annotated:"lens" %}
 extension {{ type.name }} {
   enum lens {
     {% for variable in type.variables|!static|!computed %}
     static let {{ variable.name }} = Lens<{{ type.name }}, {{ variable.typeName }}>(
       get: { $0.{{ variable.name }} },
       set: { part in
         { whole in
           {{ type.name }}.init({% for argument in type.variables|!static|!computed %}{{ argument.name }}: {% if variable.name == argument.name %}part{% else %}whole.{{ argument.name }}{% endif %}{% if not forloop.last %}, {% endif %}{% endfor %})
         }
       }
     ){% endfor %}
   }
 }
 {% endfor %}

 
 
 -- PRISM

 {% macro getTypeName type %}{% if type.actualTypeName %}{{ type.actualTypeName.name }}{% else %}{{ type.typeName.name }}{% endif %}{% endmacro %}

 {%  for type in types.all where type.name == "SourceryImports_Prism" %}
 {% for variable in type.variables %}
 {% if variable|annotated:"testable" %}@testable {% else %}{% endif %}import {{ variable.name }}
 {% endfor %}

 {% endfor %}

 {% for type in types.enums|annotated:"prism" %}

 extension {{ type.name }} {
     {{ type.accessLevel }} enum prism {
         {% for case in type.cases %}
     {% if type.isGeneric %}
     {% if case.hasAssociatedValue %}
     {{ type.accessLevel }} static var {{ case.name }}: Prism<{{ type.name }},{% if case.associatedValues.count > 1 %}({% for associated in case.associatedValues %}{% call getTypeName associated %}{% if forloop.last %}{% else %}, {% endif %}{% endfor %}){% else %}{% call getTypeName case.associatedValues.first %}{% endif %}> {
       return .init(
         tryGet: { if case .{{ case.name }}(let value) = $0 { return value } else { return nil } },
         inject: { ({% for associated in case.associatedValues %}x{{ forloop.counter}}{% if not forloop.last%}, {% endif %}{% endfor %}) in .{{ case.name }}({% for associated in case.associatedValues %}{% if associated.localName != nil %}{{ associated.localName }}:{% endif %}x{{ forloop.counter }}{% if not forloop.last%}, {% endif %}{% endfor %}) })
     }
     {% else %}
     {{ type.accessLevel }} static var {{ case.name }}: Prism<{{ type.name }}, ()> {
       return .init(
         tryGet: { if case .{{ case.name }} = $0 { return () } else { return nil } },
         inject: { .{{ case.name }} })
     }
     {% endif %}
     {% else %}
         {% if case.hasAssociatedValue %}
         {{ type.accessLevel }} static let {{ case.name }} = Prism<{{ type.name }},{% if case.associatedValues.count > 1 %}({% for associated in case.associatedValues %}{% call getTypeName associated %}{% if forloop.last %}{% else %}, {% endif %}{% endfor %}){% else %}{% call getTypeName case.associatedValues.first %}{% endif %}>(
             tryGet: { if case .{{ case.name }}(let value) = $0 { return value } else { return nil } },
             inject: { ({% for associated in case.associatedValues %}x{{ forloop.counter}}{% if not forloop.last%}, {% endif %}{% endfor %}) in .{{ case.name }}({% for associated in case.associatedValues %}{% if associated.localName != nil %}{{ associated.localName }}:{% endif %}x{{ forloop.counter }}{% if not forloop.last%}, {% endif %}{% endfor %}) })
         {% else %}
         {{ type.accessLevel }} static let {{ case.name }} = Prism<{{ type.name }}, ()>(
             tryGet: { if case .{{ case.name }} = $0 { return () } else { return nil } },
             inject: { .{{ case.name }} })
         {% endif %}
     {% endif %}

         {% endfor %}
     }
 }

 {% if type.annotations.prism == "chain" %}
 {{ type.accessLevel }} extension PrismType where SType == TType, AType == BType, BType == {{ type.name }} {
   {% for case in type.cases %}
   {% if case.hasAssociatedValue %}
   var {{ case.name }}: Prism<SType,{% if case.associatedValues.count > 1 %}({% for associated in case.associatedValues %}{% call getTypeName associated %}{% if forloop.last %}{% else %}, {% endif %}{% endfor %}){% else %}{% call getTypeName case.associatedValues.first %}{% endif %}> {
     return self >>> {{ type.name }}.prism.{{ case.name }}
   }
   {% else %}
   var {{ case.name }}: Prism<SType,()> {
     return self >>> {{ type.name }}.prism.{{ case.name }}
   }
   {% endif %}

   {% endfor %}
 }
 {% endif %}

 {% endfor %}

 
 */
