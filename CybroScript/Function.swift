//
//  Function.swift
//  CybroScript
//
//  Created by Simon Ferns on 2024/06/15.
//

import Foundation

protocol Function {
    func call(_ interpreter: Interpreter_, _ arguments: [Any]) -> Any?
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
    
    init(_ declaration: FunctionDecl) {
        self.declaration = declaration
    }
    
    func call(_ interpreter: Interpreter_, _ arguments: [Any]) -> Any? {
        let environment = Environment(enclosing: interpreter.environemnt)
        for (parameter, argument) in zip(declaration.params, arguments) {
            environment.define(name: parameter.lexeme, value: argument)
        }
        
        interpreter.executeBlock(declaration.body, environment)
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
    func call(_ interpreter: Interpreter_, _ arguments: [Any]) -> Any? {
        return Double(Date().timeIntervalSince1970)
    }
    
    func arity() -> Int {
        return 0
    }

}


class FunctionCallablePrintLn: Function {
    func call(_ interpreter: Interpreter_, _ arguments: [Any]) -> Any? {
        print(arguments[0])
        return nil
    }
    
    func arity() -> Int {
        1
    }
   
}
