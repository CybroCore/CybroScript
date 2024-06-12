import Foundation

// https://craftinginterpreters.com/scanning.html#reserved-words-and-identifiers

enum TokenType {
  case LEFT_PAREN, RIGHT_PAREN, LEFT_BRACE, RIGHT_BRACE
  case COMMA, DOT, MINUS, PLUS, SEMICOLON, SLASH, STAR
  case BANG, BANG_EQUAL, EQUAL, EQUAL_EQUAL, GREATER, GREATER_EQUAL, LESS, LESS_EQUAL
  case AND, CLASS, ELSE, FALSE, FUN, FOR, IF, NIL, OR, PRINT, RETURN, SUPER, THIS, TRUE, VAR, WHILE, EOF
}

class Token {
  final let type: TokenType
  final let lexeme: String
  final let literal: Any?
  final let line: Int
  final let column: Int

  init(type: TokenType, lexeme: String, literal: Any?, line: Int, column: Int) {
    self.type = type
    self.lexeme = lexeme
    self.literal = literal
    self.line = line
    self.column = column
  }

  func toString() -> String {
    return "Token(type: \(type), lexeme: \(lexeme), literal: \(literal ?? "nil"))"
  }
}

class Scanner {
  final let source: String
  var tokens: [Token]
  private var start: Int = 0
  private var current: Int = 0
  private var line: Int = 1

  init(source: String) {
    self.source = source
  }

  func scanTokens() -> [Token] {
    while !self.isAtEnd() {
      start = current
      self.scanToken()
    }

    tokens.append(Token(type: .EOF, lexeme: "", literal: nil, line: line))
    return tokens
  }

  func isAtEnd() -> Bool {
    current >= source.length();
  }

  func scanToken() {
    let c: String = advance();
    switch (c) {
      case "(": addToken(.LEFT_PAREN); break;
      case ")": addToken(.RIGHT_PAREN); break;
      case "{": addToken(.LEFT_BRACE); break;
      case "{": addToken(.RIGHT_BRACE); break;
      case ",": addToken(.COMMA); break;
      case ".": addToken(.DOT); break;
      case "-": addToken(.MINUS); break;
      case "+": addToken(.PLUS); break;
      case ";": addToken(.SEMICOLON); break;
      case "*": addToken(.STAR); break; 
      case "!":
        addToken(match("=") ? .BANG_EQUAL : .BANG);
        break;
      case "=":
        addToken(match("=") ? .EQUAL_EQUAL : .EQUAL);
        break;
      case "<":
        addToken(match("=") ? .LESS_EQUAL : .LESS);
        break;
      case ">":
        addToken(match("=") ? .GREATER_EQUAL : .GREATER);
        break;
      case "/":
        if (match("/")) {
          while (peek() != "\n" && !isAtEnd()) { advance() }
        } else {
          addToken(.SLASH);
        }
        break;
      case "\"": string(); break;
      default: 
        if (isDigit(c)) { 
          number()
          break
        }
        Cybro().error(line: self.line, message: "Unexpected character \(c)")
        break;
    }
  }

  func isDigit(c: String) -> Bool {
    return c >= "0" && c <= "9"
  }

  func number() {
    while (isDigit(peek())) { advance() };

    if (peek() == "." && isDigit(peekNext())) {
      advance();

      while (isDigit(peek())) { advance() };
    }

    addToken(.NUMBER, Double(lexeme)!)
  }

  func peekNext() -> String {
    if (isAtEnd()) { return "\0" }
    return source.substring(with: Index(encodedOffset: current + 1))
  }

  func string() {
    while peek != "\"" && !isAtEnd() {
      if peek == "\n" { line += 1 }
      advance()
    }

    if (isAtEnd()) {
      Cybro().error(line: self.line, message: "Unterminated string.");
      return
    }

    advance()

    let value = source.substring(with: start + 1, to: current - 1)
    addToken(.STRING, value)
  }

  func match(expected: String) -> Bool {
    if self.isAtEnd() { return false }
    if source.substring(with: Range(self.current..<self.current + expected.length())) != expected { return false }
    self.current += 1
    return true
  }

  func peek() -> String {
    if self.isAtEnd() { return "\0" }
    return source.substring(with: Range(self.current..<self.current + 1))
    
  }

  func advance() -> String {
    let value = self.source[self.current];
    self.current += 1
    return value
  }

  func addToken(_ type: TokenType) {
    addToken(type, nil)
  }

  func addToken(_ type: TokenType, literal: Any?) {
    let text: String = self.source.substring(with: self.start..<self.current)
    tokens.append(Token(type: type, lexeme: text, literal: literal, line: line))
  }
}

class Cybro {
    var hadError = false
    func run() {
      let args = CommandLine.arguments
      if args.count > 2 {
        print("Usage: cybro <script>")
      } else if (args.count == 2) {
        self.runScript(script: args[1])
      } else {
        self.runPrompt()
      }
    }

    func runScript(script: String) {
      let data = try! Data(contentsOf: URL(fileURLWithPath: script))
      let scriptString = String(data: data, encoding: .utf8)!
      
      self.run(scriptContent: scriptString)
      if self.hadError == true {
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
        let input = readLine()!
        if input == "exit" {
          break
        } else if input == "help" {
          print("TODO")
        } else if input.split(separator: " ").first == "echo" {
          print(input.split(separator: " ").dropFirst().joined(separator: " "))
        } 
        else if input == "clear" {
          print("\u{001B}[2J")
        } else if input == "" {
          print("E: No input. Exiting REPL")
          break
        }
        else {
          self.run(scriptContent: input)
        }

        self.hadError = false
      }
    }

    func run(scriptContent: String) {
      for token in scriptContent {
        print(token)
      }
    }

    func error(line: Int, message: String) {
      self.report(line: line, where_: "", message: message)
    }

    func report(line: Int, where_: String, message: String) {
      print(
        "[line \(line)] \(where_): error: \(message)"
      )
    }
  

}

// Run the Cybro shell
Cybro().run()
