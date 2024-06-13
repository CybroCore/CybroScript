//
//  main.swift
//  CybroScript
//
//  Created by Simon Ferns on 2024/06/13.
//

import Foundation

// https://craftinginterpreters.com/parsing-expressions.html#the-parser-class

struct Interpreter_: Visitor {
    typealias ReturnType = Any?

    func visitLiteral(_ expr: Literal) -> Any? {
        return expr.value
    }

    func visitGrouping(_ expr: Grouping) -> Any? {
        return evaluate(expr: expr.expression)
    }

    func evaluate(expr: Expr) -> Any? {
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
                if "\(left ?? "nil")" == "\(right ?? "nil")" {
                    return true
                }
                
            default:
                return nil
        }

        return nil;
}
    
    func interpret(expression_: Expr) {
        let value = evaluate(expr: expression_);
        print("\(value ?? "nil")");
      }
}

enum TokenType {
    case LEFT_PAREN, RIGHT_PAREN, LEFT_BRACE, RIGHT_BRACE
    case COMMA, DOT, MINUS, PLUS, SEMICOLON, SLASH, STAR
    case BANG, BANG_EQUAL, EQUAL, EQUAL_EQUAL, GREATER, GREATER_EQUAL, LESS, LESS_EQUAL
    case AND, CLASS, ELSE, FALSE, FUN, FOR, IF, NIL, OR, PRINT, RETURN, SUPER, THIS, TRUE, VAR, WHILE, EOF
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
    "nil": .NIL,
    "or": .OR,
    "print": .PRINT,
    "return": .RETURN,
    "super": .SUPER,
    "this": .THIS,
    "true": .TRUE,
    "var": .VAR,
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
        case "o":
            if match(expected: "r") && peek() == " " {
                addToken(.OR)
            }
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
        let expression = parser.parse()
        
        if hadError {
            return
        }
        
        guard let expression = expression else { return }
            interpreter.interpret(expression_: expression)
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