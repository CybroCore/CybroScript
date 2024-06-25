//
//  Function.swift
//  CybroScript
//
//  Created by Simon Ferns on 2024/06/15.
//

import Foundation

protocol Function {
    func call(_ interpreter: Interpreter_, _ arguments: [Any?]) throws -> Any?
    func arity() -> Int
    func toString() -> String
}

extension Function {
    func toString() -> String {
        return "<native function \(arity())>"
    }
}

class CybroFunction: Function {
    let declaration: FunctionDecl
    var closure: Environment
    
    init(_ declaration: FunctionDecl, _ closure: Environment) {
        self.closure = closure
        self.declaration = declaration
    }
    
    func call(_ interpreter: Interpreter_, _ arguments: [Any?]) throws -> Any? {
        let environment = Environment(enclosing: closure)
        for (parameter, argument) in zip(declaration.params, arguments) {
            environment.define(name: parameter.lexeme, value: argument)
        }
        
        do {
            try interpreter.executeBlock(declaration.body, environment)
        } catch RuntimeErrors.invalidReturnType(let value){
            return value
        }
        return nil
    }
    
    func arity() -> Int {
        return declaration.params.count
    }
    
    func toString() -> String {
        return "<fn \(declaration.name.lexeme) \(arity())>"
    }
}
class FunctionCallableClock: Function {
    func call(_ interpreter: Interpreter_, _ arguments: [Any?]) -> Any? {
        return Double(Date().timeIntervalSince1970)
    }
    
    func arity() -> Int {
        return 0
    }

}


class FunctionCallablePrintLn: Function {
    func call(_ interpreter: Interpreter_, _ arguments: [Any?]) -> Any? {
        if let fun = arguments[0] as? Function {
            print(fun.toString())
        } else {
            if let value = arguments[0] {
                print(value)
            } else {
                print("nil")
            }
        }
        return nil
    }
    
    func arity() -> Int {
        1
    }
   
}


class CybroClass: Function {
    final var name: String;
    final var methods: [String:Function] = [:]

    func call(_ interpreter: Interpreter_, _ arguments: [Any?]) throws -> Any? {
        let instance = CybroInstance(klass: self)
        return instance
    }
    
    func arity() -> Int {
        return 0
    }
    
    init(name: String, methods: [String:Function]) {
        self.name = name
        self.methods = methods
   }

  func toString() -> String {
    return name;
  }
    
    func findMethod(name: String) -> Function? {
        if let method = methods[name] {
            return method
        }
        
        return nil
    }
    
    
}

class CybroInstance: Function {
    final var fields: [String:Any] = [:]
    private var klass: CybroClass;

    func get(name: Token) -> Any? {
        if let value = fields["\(name.lexeme)"] {
            return value
        }
        
        let method = klass.findMethod(name: name.lexeme)
        if method != nil { return method }
        
        return nil
    }
    
    
    func set(name: Token , value: Any?) {
        fields[name.lexeme] = value
    }
    
    func call(_ interpreter: Interpreter_, _ arguments: [Any?]) throws -> Any? {
        return nil
    }
    
    func arity() -> Int {
        print("You can't pass arguments into an existing instance!")
        return 0
    }
    

  init(klass: CybroClass) {
    self.klass = klass;
  }

  func toString() -> String {
    return klass.name + " instance";
  }
}
