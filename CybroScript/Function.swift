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
