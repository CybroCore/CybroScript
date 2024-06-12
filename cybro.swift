import Foundation

enum TokenType {
    case LEFT_PAREN, RIGHT_PAREN, LEFT_BRACE, RIGHT_BRACE
    case COMMA, DOT, MINUS, PLUS, SEMICOLON, SLASH, STAR
    case BANG, BANG_EQUAL, EQUAL, EQUAL_EQUAL, GREATER, GREATER_EQUAL, LESS, LESS_EQUAL
    case AND, CLASS, ELSE, FALSE, FUN, FOR, IF, NIL, OR, PRINT, RETURN, SUPER, THIS, TRUE, VAR, WHILE, EOF
    case NUMBER, STRING // Added STRING case
}

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
            if match(expected: "/") {
                while peek() != "\n" && !isAtEnd() { advance() }
            } else {
                addToken(.SLASH)
            }
        case "\"": string()
        default:
            let char = c
            if isDigit(String(char)) {
                number()
            } else {
                Cybro().error(line: self.line, message: "Unexpected character \(c)")
            }
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
            Cybro().error(line: self.line, message: "Unterminated string.")
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

        for token in tokens {
            print(token.toString())
        }
    }

    func error(line: Int, message: String) {
        report(line: line, where_: "", message: message)
    }

    func report(line: Int, where_: String, message: String) {
        print("[line \(line)] \(where_): error: \(message)")
    }
}

// Run the Cybro shell
let val = Cybro()
val.run()

