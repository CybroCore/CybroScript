import Foundation

class FileWriter {
    private let path: String
    private var content = ""
    
    init(_ path: String) {
        self.path = path
    }
    
    func writeLine(_ line: String = "") {
        content += line + "\n"
    }
    
    func close() {
        do {
            print(path)
            try content.write(toFile: path, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to write to file \(path)")
            exit(1)
        }
    }
}

struct GenerateAst {
    func run() {
        let args = CommandLine.arguments
        print("Arguments: \(args)")  // Debugging output
        if args.count != 2 {
            print("Usage: generate_ast <output directory>")
            exit(64)
        }
        let outputDir = args[1]
        defineAst(outputDir, "Declarations", [
            "Binary   : left: Declarations, operator_: Token, right: Declarations",
            "Grouping : expression: Declarations",
            "Literal  : value: Any?",
            "Unary    : operator_: Token, right: Declarations",
            "Ternary  : value1: Any?, op1: Token, value2: Any, op2: Token, value3: Any?",
            "Block      : statements: [Declarations]",
            "Expression : expression: Declarations",
            "Print      : expression: Declarations",
            "Var        : name: Token, initializer: Declarations",
            "Let        : name: Token, intializer: Declarations",
            "Variable : name: Token",
            "Assign   : name: Token, value: Declarations",
            ]);
    }

    func defineAst(_ outputDir: String, _ baseName: String, _ types: [String]) {
        let path = "\(outputDir)/\(baseName).swift"
        let writer = FileWriter(path)
        
        writer.writeLine("import Foundation")
        writer.writeLine()
        
        writer.writeLine("protocol \(baseName) {")
        writer.writeLine("    func accept<V: Visitor>(_ visitor: V) -> Any?")
        writer.writeLine("}")
        writer.writeLine()
        
        defineVisitor(writer, baseName, types)
        writer.writeLine()
        
        for type in types {
            let parts = type.split(separator: ":", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
            guard parts.count == 2 else {
                print("Error: Type format is incorrect: \(type)")
                exit(1)
            }
            let className = parts[0]
            let fields = parts[1]
            defineType(writer, baseName, className, fields)
        }
        
        writer.close()
    }

    func defineType(_ writer: FileWriter, _ baseName: String, _ className: String, _ fieldList: String) {
        writer.writeLine("class \(className): \(baseName) {")
        
        let fields = fieldList.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        for field in fields {
            writer.writeLine("    let \(field)")
        }
        writer.writeLine()
        
        writer.writeLine("    init(\(fieldList)) {")
        for field in fields {
            let nameParts = field.split(separator: " ").map { $0.trimmingCharacters(in: .whitespaces) }
            guard nameParts.count == 2 else {
                print("Error: Field format is incorrect: \(field)")
                exit(1)
            }
            writer.writeLine("        self.\(nameParts[0].replacingOccurrences(of: ":", with: "")) = \(nameParts[0].replacingOccurrences(of: ":", with: ""))")
        }
        writer.writeLine("    }")
        writer.writeLine()
        
        writer.writeLine("    func accept<V: Visitor>(_ visitor: V) -> Any? {")
        writer.writeLine("        return visitor.visit\(className)(self)")
        writer.writeLine("    }")
        writer.writeLine("}")
        writer.writeLine()
    }

    func defineVisitor(_ writer: FileWriter, _ baseName: String, _ types: [String]) {
        writer.writeLine("protocol Visitor {")
        for type in types {
            let typeName = type.split(separator: ":").first!.trimmingCharacters(in: .whitespaces)
            writer.writeLine("    func visit\(typeName)(_ \(baseName.lowercased()): \(typeName)) -> Any?")
        }
        writer.writeLine("}")
    }
}

func runGenerator() {
    GenerateAst().run()
}

