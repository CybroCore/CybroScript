//
//  Parser.swift
//  CybroScript
//
//  Created by Simon Ferns on 2024/06/13.
//

import Foundation

enum ParseError: Error {
    case SomeError
}

class Parser {
    final let tokens: [Token]
    var current: Int
    
    init(tokens: [Token], current: Int = 0) {
        self.tokens = tokens
        self.current = current
    }
    
    func expression() throws -> Declarations {
        return try assignment()
    }
    
    func assignment() throws -> Declarations {
        let expr = try or()
        
        if match(types: .EQUAL) {
            let equals = previous()
            let value = try assignment()
            
            if let expr = expr as? Variable {
                let name = expr.name
                return Assign(name: name, value: value)
            }
            
            throw error(token: equals, message: "Invalid assignment target.")
        }
        
        return expr
    }
    
    func or() throws -> Declarations {
        var expr = try and()
        
        while match(types: .OR) {
            let operator_ = previous()
            let right = try and()
            expr = Logical(left: expr, operator_: operator_, right: right)
        }
        
        return expr
    }
    
    func and() throws -> Declarations {
        var expr = try equality()
        
        while match(types: .AND) {
            let operator_ = previous()
            let right = try equality()
            expr = Logical(left: expr, operator_: operator_, right: right)
        }
        
        return expr
    }
    
    func equality() throws -> Declarations {
        var expr: Declarations = try comparison()
        
        while match(types: .BANG_EQUAL, .EQUAL_EQUAL) {
            let operator_ = previous()
            let right = try comparison()
            expr = Binary(left: expr, operator_: operator_, right: right)
        }
        
        return expr
    }
    
    func comparison() throws -> Declarations {
        var expr = try term();
        
        while (match(types: .GREATER, .GREATER_EQUAL, .LESS, .LESS_EQUAL, .MIN, .MAX)) {
            var operator_ = previous();
            var right = try term();
            expr = Binary(left: expr, operator_: operator_, right: right)
        }
        
        return expr;
    }
    
    func term() throws -> Declarations {
        var expr = try factor();
        
        while (match(types: .MINUS, .PLUS)) {
            var operator_ = previous();
            var right = try factor();
            expr = Binary(left: expr, operator_: operator_, right: right);
        }
        
        return expr;
    }
    
    func factor() throws -> Declarations {
        var expr = try unary();
        
        while (match(types: .SLASH, .STAR)) {
            var operator_ = previous();
            var right = try unary();
            expr = Binary(left: expr, operator_: operator_, right: right)
        }
        
        return expr;
    }
    
    func match(types: TokenType...) -> Bool {
        for token in types {
            if check(type: token) {
                advance()
                return true
            }
        }
        
        return false
    }
    
    func check(type: TokenType) -> Bool {
        if (isAtEnd()) { return false }
        return peek().type == type;
    }
    
    func advance() -> Token {
        if !isAtEnd() {
            current += 1
        }
        return previous()
    }
    
    func isAtEnd() -> Bool {
        return peek().type == .EOF
    }
    
    func peek() -> Token {
        return tokens[current]
    }
    
    func previous() -> Token {
        return tokens[current - 1]
    }
    
    func unary() throws -> Declarations {
        if (match(types: .BANG, .MINUS)) {
            var operator_ = previous();
            var right = try unary();
            return Unary(operator_: operator_, right: right)
        }
            
        return try call()
    }
    
    
    func call() throws -> Declarations {
        var expr = try primary();

        while true {
            if match(types: .LEFT_PAREN) {
            expr = try finishCall(expr);
          } else {
            break;
          }
        }

        return expr;
      }
    
    func finishCall(_ callee: Declarations) throws -> Declarations {
        var arguments: [Declarations] = []
        if !check(type: .RIGHT_PAREN) {
          while match(types: .COMMA) {
              if arguments.count >= 255 {
                  try error(token: peek(), message: "Can't have more than 255 arguments!")
              }
            arguments.append(try expression());
          }
        }
        let paren = try consume(type: .RIGHT_PAREN, message: "Expect ')' after arguments.")
        return Call(calee: callee, paren: paren, arguments: arguments)
      }
    
    func primary() throws -> Declarations {
        if (match(types: .FALSE)) { return Literal(value: false) };
        if (match(types: .TRUE)) { return Literal(value: true) };
        if (match(types: .NIL)) { return Literal(value: nil) };
        
        if (match(types: .NUMBER, .STRING)) {
            return Literal(value: previous().literal)
        }
        
        if (match(types: .IDENTIFIER)) {
              return Variable(name: previous());
        }
        
        if (match(types: .LEFT_PAREN)) {
            var expr = try expression();
            try consume(type: .RIGHT_PAREN, message: "Expect ')' after expression.");
            return Grouping(expression: expr)
        }
        
        throw error(token: peek(), message: "Expect expression.");
    }
    
    func consume(type: TokenType , message: String ) throws -> Token {
        if (check(type: type)) {
            return advance()
        };
        
        throw error(token: peek(), message: message)
    }
    
    func error(token: Token , message: String) -> ParseError {
        Cybro.error(token: token, message: message);
        return ParseError.SomeError;
    }
    
    func synchronize() {
        advance();
        
        while (!isAtEnd()) {
            if (previous().type == .SEMICOLON) { return };
            
            switch (peek().type) {
            case .CLASS:
                return
            case .FUN:
                return
            case .VAR:
                return
            case .FOR:
                return
            case .IF:
                return
            case .WHILE:
                return
            case .PRINT:
                return
            case .RETURN:
                return;
            default:
                continue
            }
            
            advance();
        }
    }
    
    func parse() -> [Declarations]? {
        var statements: [Declarations] = []
            while !isAtEnd() {
           do {
             let out = try declaration()
               if out == nil {
                   continue
               }
             statements.append(out!)
           } catch {
               print("HANDLE THE ERROR")
           }
        }
        return statements
    }
    
    func function(_ kind: String) throws -> Declarations {
        let name = try consume(type: .IDENTIFIER, message: "Expect \(kind) Name.")
    }
    
    func declaration() -> Declarations? {
        do {
            if (match(types: .FUN)) { return try function("function") }
            if (match(types: .VAR)) { return try varDeclaration() };
            if (match(types: .LET)) { return try letDeclaration() }

          return try statement();
        } catch {
          synchronize();
          return nil
        }
      }
    
    func varDeclaration() throws -> Declarations {
        let name = try consume(type: .IDENTIFIER, message: "Expect variable name.")

        var initializer: Declarations? = nil;
        if (match(types: .EQUAL)) {
          initializer = try expression();
        }

        try consume(type: .SEMICOLON, message: "Expect ';' after variable declaration.")
        return Var(name: name, initializer: initializer!);
      }
    
    func letDeclaration() throws -> Declarations {
        let name = try consume(type: .IDENTIFIER, message: "Expect variable name.")

        var initializer: Declarations? = nil;
        if (match(types: .EQUAL)) {
          initializer = try expression();
        }

        try consume(type: .SEMICOLON, message: "Expect ';' after variable declaration.")
        return Let(name: name, intializer: initializer!);
      }
    
    func statement() throws -> Declarations {
        if match(types: .FOR) { return try forStatement() }
        if match(types: .IF) { return try ifStatement() }
        if match(types: .PRINT) { return try printStatement() };
        if match(types: .WHILE) { return try whileStatement() };
        if match(types: .BREAK) { return try breakStatement() }
        if match(types: .LEFT_BRACE) { return try Block(statements: block())}

        return try expressionStatement();
      }
    
    func breakStatement() throws -> Declarations {
        try consume(type: .SEMICOLON, message: "Expect ';' after break statement")
        return Break(level: 1)
    }
    
    func forStatement() throws -> Declarations {
        try consume(type: .LEFT_PAREN, message: "Expect '(' after for condition")
        
        var intializer: Declarations? = nil
        if match(types: .SEMICOLON) {
            intializer = nil
        } else if match(types: .VAR) {
            intializer = try varDeclaration()
        } else {
            intializer = try expressionStatement();
        }
        
        var condition: Declarations? = nil
        if (!check(type: .SEMICOLON)) {
            condition = try expression()
        }
        try consume(type: .SEMICOLON, message: "Expect ';' after loop condition.")
            
        var increment: Declarations? = nil
        if (!check(type: .RIGHT_PAREN)) {
            increment = try expression()
        }
        try consume(type: .RIGHT_PAREN, message: "Expect ')' after for clauses.")
        
        var body = try statement()
        
        if let increment = increment {
            body = Block(statements: [
                body,
                Expression(expression: increment)
            ])
        }
        
        if condition == nil {
            condition = Literal(value: true)
        }
        body = While(condition: condition!, body: body)
        
        if let intializer = intializer {
            body = Block(statements: [
                intializer,
                body
            ])
        }
        
        return body
    }
    
    func whileStatement() throws -> Declarations {
        try consume(type: .LEFT_PAREN, message: "Expect '(' after if condition")
        let condition = try expression();
        try consume(type: .RIGHT_PAREN, message: "Expect ')' after if condition.");
        let body = try statement()
        
        return While(condition: condition, body: body)
   }
    
    func ifStatement() throws -> Declarations {
        try consume(type: .LEFT_PAREN, message: "Expect '(' after if condition")
        let condition = try expression();
        try consume(type: .RIGHT_PAREN, message: "Expect ')' after if condition.");

        let thenBranch = try statement();
        var elseBranch: Declarations? = nil;
        if (match(types: .ELSE)) {
          elseBranch = try statement();
        }
        
        return If(condition: condition, thenBranch: thenBranch, elseBranch: elseBranch)
      }
    
    func block() throws -> [Declarations] {
        var statements: [Declarations] = [];

        while !check(type: .RIGHT_BRACE) && !isAtEnd() {
            if let decl = declaration() {
                statements.append(decl)
            }
        }

        try consume(type: .RIGHT_BRACE, message: "Expected '}' after block.");
        return statements;
    }
    
    func printStatement() throws -> Declarations {
        let value = try expression();
        try consume(type: .SEMICOLON, message: "Expect ';' after value.");
        return Print(expression: value);
      }
    
    func expressionStatement() throws -> Declarations {
        let expr = try expression();
        try consume(type: .SEMICOLON, message: "Expect ';' after expression.");
        return Expression(expression: expr);
      }
    
}
