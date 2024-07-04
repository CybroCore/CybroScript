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
            "If         : condition: Declarations, thenBranch: Declarations, elseBranch: (Declarations)?",
            "Assign   : name: Token, value: Declarations",
            "Logical  : left: Declarations, operator_: Token, right: Declarations",
            "While    : condition: Declarations, body: Declarations",
            "Break    : level: Int",
            "Call     : calee: Declarations, paren: Token, arguments: [Declarations]", "Class      : name: Token, methods: [FunctionDecl], superclass: Variable?",
            "Get      : object: Declarations, name: Token",
            "Set_      : object: Declarations, name: Token, value: Declarations",
            "Super_     : keyword: Token, method: Token",
            "Subscript     : object: Declarations, index: Declarations",
            "PrimitiveArray     : values: [Declarations]",
            "This      : keyword: Token",
            "FunctionDecl: name: Token, params: [Token], body: [Declarations]",
            "Return: keyword: Token, value: Declarations, level: Int"
            ]);
    }

    func defineAst(_ outputDir: String, _ baseName: String, _ types: [String]) {
        let path = "\(outputDir)/\(baseName).swift"
        let writer = FileWriter(path)
        
        writer.writeLine("import Foundation")
        writer.writeLine()
        
        writer.writeLine("protocol \(baseName): Hashable {")
        writer.writeLine("    func accept<V: Visitor>(_ visitor: V) throws -> Any?")
        writer.writeLine("    var id: UUID { get }")
        writer.writeLine("}")
        writer.writeLine()
        
        writer.writeLine("extension \(baseName) {")
        writer.writeLine("    func hash(into hasher: inout Hasher) {")
        writer.writeLine("        hasher.combine(id)")
        writer.writeLine("    }")
        writer.writeLine("}")

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
                writer.writeLine("    let \(field.replacingOccurrences(of: "Declarations", with: "any Declarations"))")
        }
        writer.writeLine("    let id: UUID = UUID()")
        writer.writeLine()
        
        writer.writeLine("    init(\(fieldList.replacingOccurrences(of: "Declarations", with: "any Declarations"))) {")
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
        
        writer.writeLine("    func accept<V: Visitor>(_ visitor: V) throws -> Any? {")
        writer.writeLine("        return try visitor.visit\(className)(self)")
        writer.writeLine("    }")
        writer.writeLine()
        writer.writeLine("    static func == (lhs: \(className), rhs: \(className)) -> Bool {")
        writer.writeLine("        return lhs.id == rhs.id")
        writer.writeLine("    }")
        writer.writeLine("}")
        writer.writeLine()
    }

    func defineVisitor(_ writer: FileWriter, _ baseName: String, _ types: [String]) {
        writer.writeLine("protocol Visitor {")
        for type in types {
            let typeName = type.split(separator: ":").first!.trimmingCharacters(in: .whitespaces)
            writer.writeLine("    func visit\(typeName)(_ \(baseName.lowercased()): \(typeName)) throws -> Any?")
        }
        writer.writeLine("}")
    }
}

func runGenerator() {
    GenerateAst().run()
}

