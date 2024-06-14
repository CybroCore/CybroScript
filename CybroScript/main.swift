//
//  main.swift
//  CybroScript
//
//  Created by Simon Ferns on 2024/06/13.
//

import Foundation

// https://craftinginterpreters.com/statements-and-state.html#nesting-and-shadowing
// Close to the end.

class Environment {
    var enclosing: Environment?
    var storage: [String : Any?] = [:]
    
    init(enclosing: Environment? = nil, storage: [String : Any?] = [:]) {
        self.enclosing = enclosing
        self.storage = storage
    }
    
    func define(name: String, value: Any?) {
        if storage.keys.contains("let-\(name)") {
            print("RAISE ERROR, NOT ALLOWED TO HAVE 2 VARIABLES WITH SAME NAME")
            return
        }
        
        storage[name] = value
    }
    
    func defineLet(name: String, value: Any?) {
        if storage.keys.contains(name) {
            print("RAISE ERROR, NOT ALLOWED TO HAVE 2 VARIABLES WITH SAME NAME")
            return
        }
        storage["let-\(name)"] = value
    }
    
    func get(name: Token) -> Any? {
        if storage.keys.contains(name.lexeme) {
            return storage[name.lexeme]
        } else if storage.keys.contains("let-\(name.lexeme)") {
            return storage["let-\(name.lexeme)"]
        }
        
        if let enclosing = enclosing {
            return enclosing.get(name: name)
        }
        
        print("IMPLEMENT THROW RUNTIME ERROR \(name.lexeme)")
        return ""
    }
    
    func assign(_ name: Token, _ value: Any) {
        if storage.keys.contains(name.lexeme) {
          storage[name.lexeme] = value;
          return;
        } else if storage.keys.contains("let-\(name.lexeme)") {
            print("THROW CAN'T ASSIGN TO CONSTANT")
        }
        
        if let enclosing = enclosing {
          enclosing.assign(name, value);
          return;
        }
        
        print("IMPLEMENT THROW RUNTIME ERROR")
      }
}

class Interpreter_: Visitor {
   
    var environemnt = Environment()
    
    init(environemnt: Environment = Environment()) {
        self.environemnt = environemnt
    }
    
    func visitIf(_ declarations: If) -> Any? {
        if isTruthy(evaluate(expr: declarations.condition)) {
            return execute(stmt: declarations.thenBranch)
        } else if let elseBranch = declarations.elseBranch {
            return execute(stmt: elseBranch)
        }
        return nil
    }
    
    
    func visitBlock(_ stmt: Block) -> Any? {
        executeBlock(stmt.statements, Environment(enclosing: environemnt));
        return nil
    }
      
     func executeBlock(_ statements: [Declarations], _ environemnt: Environment) {
         let previous = self.environemnt
         do {
             self.environemnt = environemnt
             
             for statement in statements {
                 execute(stmt: statement)
             }
         }
         self.environemnt = previous
    }
    
     func visitAssign(_ declarations: Assign) -> Any? {
        var value = evaluate(expr: declarations.value)
        environemnt.assign(declarations.name, value!)
        return value
    }
    
    func visitLet(_ declarations: Let) -> Any? {
        var value = evaluate(expr: declarations.intializer)
        
        environemnt.defineLet(name: declarations.name.lexeme, value: value)
        return nil
    }
    
    func visitVar(_ declarations: Var) -> Any? {
        var value = evaluate(expr: declarations.initializer)
        
        environemnt.define(name: declarations.name.lexeme, value: value)
        return nil
    }
    
    func visitVariable(_ declarations: Variable) -> Any? {
        return environemnt.get(name: declarations.name)
    }
    
    func visitTernary(_ declarations: Ternary) -> Any? {
        return ""
    }
    
    func visitExpression(_ declarations: Expression) -> Any? {
        evaluate(expr: declarations.expression)
    }
    
    func visitPrint(_ declarations: Print) -> Any? {
        let value = evaluate(expr: declarations.expression)
        var out = "\(value!)".replacingOccurrences(of: "Optional(\"", with: "").replacingOccurrences(of: "\")", with: "")
        out = "\(out)".replacingOccurrences(of: "Optional(", with: "").replacingOccurrences(of: ")", with: "")
        print(out)
        return ""
    }
    
    typealias ReturnType = Any?

    func visitLiteral(_ expr: Literal) -> Any? {
        return expr.value
    }

    func visitGrouping(_ expr: Grouping) -> Any? {
        return evaluate(expr: expr.expression)
    }

    func evaluate(expr: Declarations) -> Any? {
        return expr.accept(self)
    }

    func visitUnary(_ expr: Unary) -> Any? {
        let right = evaluate(expr: expr.right)

        switch expr.operator_.type {
        case .MINUS:
            if let number = right as? Double {
                return -number
            } else if let number = Double("\(right ?? "")") {
                return -number
            } else {
                return nil
            }

        case .BANG:
            if let value = right as? Bool {
                return !value
            } else if let value = right as? String {
                if ["FALSE", "false", "False"].contains(value) {
                    return false
                } else if ["TRUE", "true", "True"].contains(value) {
                    return true
                }
                return value.count > 0 ? true : false
            } else if right == nil {
                return false
            } else if let value = right as? Double {
                return value == 0 ? false : true
            }
            return true
        default:
            return nil
        }

    }

    func visitBinary(_ expr: Binary) -> Any? {
        let left = evaluate(expr: expr.left);
        let right = evaluate(expr: expr.right);
        
            switch expr.operator_.type {
            case .MINUS:
                if let value = right as? Double, let value2 = left as? Double {
                    return value2 - value;
                }
            case .SLASH:
                if let value = right as? Double, let value2 = left as? Double {
                    return value2 / value;
                }
            case .STAR:
                if let value = right as? Double, let value2 = left as? Double {
                    return value2 * value;
                }
            case .MIN:
                if let value = right as? Double, let value2 = left as? Double {
                    if value2 > value {
                        return value
                    } else if value >= value2 {
                        return value2
                    }
                }
            case .MAX:
                if let value = right as? Double, let value2 = left as? Double {
                    if value2 > value {
                        return value2
                    } else if value >= value2 {
                        return value
                    }
                }
            case .PLUS:
                if let value2 = right as? Double, let value1 = left as? Double {
                    return value1 + value2
                } else {
                    return "\(left ?? "nil")\(right ?? "nil")"
                }
            case .GREATER:
                if let value2 = right as? Double, let value1 = left as? Double {
                    return value1 > value2;
                }
            case .GREATER_EQUAL:
                if let value2 = right as? Double, let value1 = left as? Double {
                    return value1 >= value2;
                }
            case .LESS:
                if let value2 = right as? Double, let value1 = left as? Double {
                    return value1 < value2;
                }
            case .LESS_EQUAL:
                if let value2 = right as? Double, let value1 = left as? Double {
                    return value1 <= value2
                }
            case .EQUAL_EQUAL:
                if right == nil && left == nil {
                    return true
                }
                if left == nil {
                    return false
                }
                if "\(left ?? "nil")".replacingOccurrences(of: "Optional(\"", with: "").replacingOccurrences(of: "\")", with: "").replacingOccurrences(of: "Optional(", with: "").replacingOccurrences(of: ")", with: "") == "\(right ?? "nil")".replacingOccurrences(of: "Optional(\"", with: "").replacingOccurrences(of: "\")", with: "").replacingOccurrences(of: "Optional(\"", with: "").replacingOccurrences(of: "\")", with: "") {
                    return true
                }
                
            default:
                return nil
        }

        return nil;
}
    
    func isTruthy(_ value: Any?) -> Bool {
        if value == nil {
            return false
        }
        
        if let bool = value as? Bool {
            if bool {
                return true
            }
            return false
        }
        
        if ["true", "True", "TRUE"].contains("\(value)") {
            return true
        }
        
        if let number = value as? Double {
            if number != 0 {
                return true
            }
        }
        
        return false
    }
    
    func interpret(statements: [Declarations]) {
        do {
              for statement in statements {
                  try execute(stmt: statement);
              }
            } catch {
                print("Errors")
            }
      }
    
    func execute(stmt: Declarations) {
        stmt.accept(self);
      }
}

enum TokenType {
    case LEFT_PAREN, RIGHT_PAREN, LEFT_BRACE, RIGHT_BRACE
    case COMMA, DOT, MINUS, PLUS, SEMICOLON, SLASH, STAR
    case BANG, BANG_EQUAL, EQUAL, EQUAL_EQUAL, GREATER, GREATER_EQUAL, LESS, LESS_EQUAL, MIN, MAX
    case AND, CLASS, ELSE, FALSE, FUN, FOR, IF, NIL, OR, PRINT, RETURN, SUPER, THIS, TRUE, VAR, LET, WHILE, EOF
    case NUMBER, STRING, IDENTIFIER
}

let keywords: [String: TokenType] = [
    "and": .AND,
    "class": .CLASS,
    "else": .ELSE,
    "false": .FALSE,
    "for": .FOR,
    "fun": .FUN,
    "if": .IF,
    "nyl": .NIL,
    "or": .OR,
    "print": .PRINT,
    "return": .RETURN,
    "super": .SUPER,
    "this": .THIS,
    "true": .TRUE,
    "var": .VAR,
    "let": .LET,
    "while": .WHILE
]

class Token {
    let type: TokenType
    let lexeme: String
    let literal: Any?
    let line: Int

    init(type: TokenType, lexeme: String, literal: Any?, line: Int) {
        self.type = type
        self.lexeme = lexeme
        self.literal = literal
        self.line = line
    }

    func toString() -> String {
        return "Token(type: \(type), lexeme: \(lexeme), literal: \(literal ?? "nil"))"
    }
}

class Scanner {
    let source: String
    var tokens: [Token] = []
    private var start: String.Index
    private var current: String.Index
    private var line: Int = 1

    init(source: String) {
        self.source = source
        self.start = source.startIndex
        self.current = source.startIndex
    }

    func scanTokens() -> [Token] {
        while !isAtEnd() {
            start = current
            scanToken()
        }

        tokens.append(Token(type: .EOF, lexeme: "", literal: nil, line: line))
        return tokens
    }

    func isAtEnd() -> Bool {
        current >= source.endIndex
    }

    func scanToken() {
        let c = advance()
        switch c {
        case "(": addToken(.LEFT_PAREN)
        case ")": addToken(.RIGHT_PAREN)
        case "{": addToken(.LEFT_BRACE)
        case "}": addToken(.RIGHT_BRACE)
        case ",": addToken(.COMMA)
        case ".": addToken(.DOT)
        case "-": addToken(.MINUS)
        case "+": addToken(.PLUS)
        case ";": addToken(.SEMICOLON)
        case "*": addToken(.STAR)
        case "~":
            if match(expected: "~") && peek() == " " {
                addToken(.MAX)
            } else {
                addToken(.MIN)
            }
            
        case "!":
            addToken(match(expected: "=") ? .BANG_EQUAL : .BANG)
        case "=":
            addToken(match(expected: "=") ? .EQUAL_EQUAL : .EQUAL)
        case "<":
            addToken(match(expected: "=") ? .LESS_EQUAL : .LESS)
        case ">":
            addToken(match(expected: "=") ? .GREATER_EQUAL : .GREATER)
        case "/":
            if match(expected: "*") {
                // Search for the next */
                // It can be on the same line or on a new line
                while !isAtEnd() {
                    if peek() == "*" && peekNext() == "/" {
                        advance()
                        advance()
                        break
                    } else if peek() == "\n" {
                        line += 1
                    }
                    advance()
                }
            } else if match(expected: "/") {
                while peek() != "\n" && !isAtEnd() { advance() }
            } else {
                addToken(.SLASH)
            }
        case "\"": string()
        default:
            let char = c
            if isDigit(String(char)) {
                number()
            } else if char == " " || char == "\t" || char == "\r" {
                // Ignore whitespace
            } else if char == "\n" {
                line += 1
            }
            else if isAlpha(char) {
                identifier()
            } else {
                Cybro.error(line: self.line, message: "Unexpected character \(c)")
            }
        }
    }

    func isAlphaNumeric(_ c: Character) -> Bool {
        return isAlpha(c) || isDigit(String(c))
    }

    func isAlpha(_ c: Character) -> Bool {
        (c >= "a" && c <= "z") || (c >= "A" && c <= "Z") || c == "_"
    }

    func identifier() {
        while let peeked = peek(), isAlpha(peeked) { advance() }
        
        let lexeme = String(source[start..<current])
        if let tokentype = keywords[lexeme] {
            addToken(tokentype)
        } else {
            addToken(.IDENTIFIER)
        }
      }

    func isDigit(_ c: String) -> Bool {
        c >= "0" && c <= "9"
    }

    func number() {
        while let peeked = peek(), isDigit(String(peeked)) { advance() }

        if peek() == ".", let next = peekNext(), isDigit(String(next)) {
            advance()

            while let peeked = peek(), isDigit(String(peeked)) { advance() }
        }

        let lexeme = String(source[start..<current])
        let value = Double(lexeme)!
        addToken(.NUMBER, literal: value)
    }

    func peekNext() -> Character? {
        let nextIndex = source.index(after: current)
        guard nextIndex < source.endIndex else { return nil }
        return source[nextIndex]
    }

    func string() {
        while let char = peek(), char != "\"" && !isAtEnd() {
            if char == "\n" { line += 1 }
            advance()
        }

        if isAtEnd() {
            Cybro.error(line: self.line, message: "Unterminated string.")
            return
        }

        advance() // Consume the closing "

        let value = String(source[source.index(after: start)..<source.index(before: current)])
        addToken(.STRING, literal: value)
    }

    @discardableResult func match(expected: Character) -> Bool {
        guard !isAtEnd() && source[current] == expected else { return false }
        current = source.index(after: current)
        return true
    }

    func peek() -> Character? {
        isAtEnd() ? nil : source[current]
    }

    @discardableResult func advance() -> Character {
        defer { current = source.index(after: current) }
        return source[current]
    }

    func addToken(_ type: TokenType, literal: Any? = nil) {
        let lexeme = String(source[start..<current])
        tokens.append(Token(type: type, lexeme: lexeme, literal: literal, line: line))
    }
}

class Cybro {
    var hadError = false
    let interpreter = Interpreter_()

    init() {
        self.hadError = false
    }

    func run() {
        let args = CommandLine.arguments
        if args.count > 2 {
            print("Usage: cybro <script>")
        } else if args.count == 2 {
            runScript(script: args[1])
        } else {
            runPrompt()
        }
    }

    func runScript(script: String) {
        let data = try! Data(contentsOf: URL(fileURLWithPath: script))
        let scriptString = String(data: data, encoding: .utf8)!
        run(scriptContent: scriptString)
        if hadError {
            exit(65)
        }
    }

    func runPrompt() {
        print("Welcome to Cybro!")
        print("Type 'exit' to quit")
        print("Type 'help' for help")
        print("Type 'clear' to clear the screen")
        print("Type 'run <script>' to run a script")
        print("Type 'run <script> <args...>' to run a script with arguments")

        while true {
            print("⇝ ", terminator: "")
            guard let input = readLine(), !input.isEmpty else {
                print("E: No input. Exiting REPL")
                break
            }

            switch input {
            case "exit":
                return
            case "help":
                print("TODO")
            case "clear":
                print("\u{001B}[2J")
            default:
                if input.hasPrefix("echo ") {
                    print(input.dropFirst(5))
                } else {
                    run(scriptContent: input)
                }
            }

            hadError = false
        }
    }

    func run(scriptContent: String) {
        let scanner = Scanner(source: scriptContent)
        let tokens = scanner.scanTokens()
        let parser = Parser(tokens: tokens)
        let statements = parser.parse()
        
        if hadError {
            return
        }
        
        guard let statements = statements else { return }
            interpreter.interpret(statements: statements)
    }

    static func error(line: Int, message: String) {
        report(line: line, where_: "", message: message)
    }

    static func report(line: Int, where_: String, message: String) {
        print("[line \(line)] \(where_): error: \(message)")
    }
    
    static func error(token: Token , message: String ) {
      if (token.type == .EOF) {
          report(line: token.line, where_: " at end", message: message);
      } else {
          report(line: token.line, where_: " at '" + token.lexeme + "'", message: message);
      }
    }
}


enum RunType {
    case AST
    case AST_PRINT
    case SCRIPT
}


let runType: RunType = .SCRIPT


switch runType {
    case .AST:
        runGenerator()
    case .AST_PRINT:
        runPrinter()
    case .SCRIPT:
        Cybro().run()
}
