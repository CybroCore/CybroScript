//
//  Resolver.swift
//  CybroScript
//
//  Created by Simon Ferns on 2024/06/16.
//

import Foundation

class Resolver: Visitor {
    func visitFunctionDecl(_ declarations: FunctionDecl) throws -> Any? {
        declare(declarations.name)
        define(declarations.name)
        
        resolveFunction(declarations)
        return nil
    }
    
    func visitThis(_ declarations: This) throws -> Any? {
        resolveLocal(declarations, declarations.keyword)
        return nil
    }
    
    func visitSet_(_ declarations: Set_) throws -> Any? {
        resolve(declarations.value)
        resolve(declarations.object)
        return nil
    }
    
    func visitGet(_ declarations: Get) throws -> Any? {
        resolve(declarations.object)
        return nil
    }
    
    func visitClass(_ declarations: Class) throws -> Any? {
        declare(declarations.name);
        
        beginScope()
        scopes[scopes.count - 1]["this"] = true
        
        for method in declarations.methods {
            resolveFunction(method)
        }
        endScope()
        
        define(declarations.name);
        return nil;
    }
    
    let interpreter: Interpreter_
    var scopes: [[String: Bool]] = []
    
    init(interpreter: Interpreter_) {
        self.interpreter = interpreter
    }
    
    func visitBinary(_ declarations: Binary) throws -> Any? {
        resolve(declarations.left)
        resolve(declarations.right)
        return nil
    }
    
    func visitGrouping(_ declarations: Grouping) throws -> Any? {
        resolve(declarations.expression)
        return nil
    }
    
    func visitLiteral(_ declarations: Literal) throws -> Any? {
        return nil
    }
    
    func visitUnary(_ declarations: Unary) throws -> Any? {
        resolve(declarations.right)
        return nil
    }
    
    func visitTernary(_ declarations: Ternary) throws -> Any? {
        return ""
    }
    
    func visitBlock(_ declarations: Block) throws -> Any? {
        beginScope()
        resolve(declarations.statements)
        endScope()
        return nil
    }
    
    func beginScope() {
        scopes.append([String: Bool]())
    }
    
    func resolve(_ statements: [any Declarations]) {
        for statement in statements {
            resolve(statement)
        }
    }
    
    func resolve(_ declaration: any Declarations) {
        do {
            try declaration.accept(self)
        } catch {
            print("ERROR")
        }
    }
    
    func endScope() {
        scopes.popLast()
    }
    
    func visitExpression(_ declarations: Expression) throws -> Any? {
        resolve(declarations.expression)
        return nil
    }
    
    func visitPrint(_ declarations: Print) throws -> Any? {
        resolve(declarations.expression)
        return nil
    }
    
    func visitVar(_ declarations: Var) throws -> Any? {
        declare(declarations.name)
        if declarations.initializer != nil {
            resolve(declarations.initializer)
        }
        define(declarations.name)
        return nil
    }
    
    func declare(_ name: Token) {
        if scopes.isEmpty { return }
        scopes[scopes.count - 1][name.lexeme] = false
    }
    
    func define(_ name: Token) {
        if scopes.isEmpty { return }
        scopes[scopes.count - 1][name.lexeme] = true
    }
    
    func visitLet(_ declarations: Let) throws -> Any? {
        declare(declarations.name)
        resolve(declarations.intializer)
        define(declarations.name)
        return nil
    }
    
    func visitVariable(_ declarations: Variable) throws -> Any? {
        if !scopes.isEmpty && scopes[scopes.count - 1][declarations.name.lexeme] == false {
            Cybro.error(token: declarations.name, message: "Can't read local variable in it's own initializer!")
            return nil
        }
        
        resolveLocal(declarations, declarations.name)
        return nil
    }
    
    func resolveLocal(_ expr: any Declarations, _ name: Token) {
        for index_ in (0..<scopes.count).reversed() {
            if scopes[index_].keys.contains(name.lexeme) {
                interpreter.resolve(expr, scopes.count - 1 - index_)
                return
            }
        }
    }
    
    func visitIf(_ declarations: If) throws -> Any? {
        resolve(declarations.condition)
        resolve(declarations.thenBranch)
        if let elseBranch = declarations.elseBranch {
            resolve(elseBranch)
        }
        return nil
    }
    
    func visitAssign(_ declarations: Assign) throws -> Any? {
        resolve(declarations.value)
        resolveLocal(declarations, declarations.name)
        return nil
    }
    
    func visitLogical(_ declarations: Logical) throws -> Any? {
        resolve(declarations.left)
        resolve(declarations.right)
        return nil
    }
    
    func visitWhile(_ declarations: While) throws -> Any? {
        resolve(declarations.condition)
        resolve(declarations.body)
        return nil
    }
    
    func visitBreak(_ declarations: Break) throws -> Any? {
        return ""
    }
    
    func visitCall(_ declarations: Call) throws -> Any? {
        resolve(declarations.calee)
        
        for argument in declarations.arguments {
            resolve(argument)
        }
        
        return nil
    }
    
    func resolveFunction(_ funct: FunctionDecl) {
        beginScope()
        for token in funct.params {
            declare(token)
            define(token)
        }
        resolve(funct.body)
        endScope()
    }
    
    func visitReturn(_ declarations: Return) throws -> Any? {
        if declarations.value != nil {
            resolve(declarations.value)
        }
        return nil
    }
}
