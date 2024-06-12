import Foundation

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
