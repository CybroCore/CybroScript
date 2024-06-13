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
        return try equality()
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
        
        return try primary();
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
    
    func declaration() -> Declarations? {
        do {
            if (match(types: .VAR)) { return try varDeclaration() };

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
    
    func statement() throws -> Declarations {
        if match(types: .PRINT) { return try printStatement() };

        return try expressionStatement();
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
