//
//  Environment.swift
//  CybroScript
//
//  Created by Simon Ferns on 2024/06/13.
//

import Foundation

struct Environment {
    var storage: [String : Any] = [:]
    
    mutating func define(name: String, value: Any?) {
        storage[name] = value
    }
    
    func get(name: Token) -> Any {
        if storage.keys.contains(name.lexeme) {
            return storage[name.lexeme]
        }
        
        print("IMPLEMENT THROW RUNTIME ERROR")
        return ""
    }
}
