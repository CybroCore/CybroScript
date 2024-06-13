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
        defineAst(outputDir, "Expr", [
            "Binary   : left: Expr, operator_: Token, right: Expr",
            "Grouping : expression: Expr",
            "Literal  : value: Any?",
            "Unary    : operator_: Token, right: Expr"
        ])
    }

    func defineAst(_ outputDir: String, _ baseName: String, _ types: [String]) {
        let path = "\(outputDir)/\(baseName).swift"
        let writer = FileWriter(path)
        
        writer.writeLine("import Foundation")
        writer.writeLine()
        
        writer.writeLine("protocol \(baseName) {}")
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
            let name = nameParts[1]
            writer.writeLine("        self.\(name) = \(name)")
        }
        writer.writeLine("    }")
        writer.writeLine("}")
        writer.writeLine()
    }
}

GenerateAst().run()

