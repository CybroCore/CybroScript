import Foundation

protocol Declarations: Hashable {
    func accept<V: Visitor>(_ visitor: V) throws -> Any?
    var id: UUID { get }
}

extension Declarations {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
protocol Visitor {
    func visitBinary(_ declarations: Binary) throws -> Any?
    func visitGrouping(_ declarations: Grouping) throws -> Any?
    func visitLiteral(_ declarations: Literal) throws -> Any?
    func visitUnary(_ declarations: Unary) throws -> Any?
    func visitTernary(_ declarations: Ternary) throws -> Any?
    func visitBlock(_ declarations: Block) throws -> Any?
    func visitExpression(_ declarations: Expression) throws -> Any?
    func visitPrint(_ declarations: Print) throws -> Any?
    func visitVar(_ declarations: Var) throws -> Any?
    func visitLet(_ declarations: Let) throws -> Any?
    func visitVariable(_ declarations: Variable) throws -> Any?
    func visitIf(_ declarations: If) throws -> Any?
    func visitAssign(_ declarations: Assign) throws -> Any?
    func visitLogical(_ declarations: Logical) throws -> Any?
    func visitWhile(_ declarations: While) throws -> Any?
    func visitBreak(_ declarations: Break) throws -> Any?
    func visitCall(_ declarations: Call) throws -> Any?
    func visitClass(_ declarations: Class) throws -> Any?
    func visitGet(_ declarations: Get) throws -> Any?
    func visitSet_(_ declarations: Set_) throws -> Any?
    func visitSuper_(_ declarations: Super_) throws -> Any?
    func visitThis(_ declarations: This) throws -> Any?
    func visitFunctionDecl(_ declarations: FunctionDecl) throws -> Any?
    func visitReturn(_ declarations: Return) throws -> Any?
}

class Binary: Declarations {
    let left: any Declarations
    let operator_: Token
    let right: any Declarations
    let id: UUID = UUID()

    init(left: any Declarations, operator_: Token, right: any Declarations) {
        self.left = left
        self.operator_ = operator_
        self.right = right
    }

    func accept<V: Visitor>(_ visitor: V) throws -> Any? {
        return try visitor.visitBinary(self)
    }

    static func == (lhs: Binary, rhs: Binary) -> Bool {
        return lhs.id == rhs.id
    }
}

class Grouping: Declarations {
    let expression: any Declarations
    let id: UUID = UUID()

    init(expression: any Declarations) {
        self.expression = expression
    }

    func accept<V: Visitor>(_ visitor: V) throws -> Any? {
        return try visitor.visitGrouping(self)
    }

    static func == (lhs: Grouping, rhs: Grouping) -> Bool {
        return lhs.id == rhs.id
    }
}

class Literal: Declarations {
    let value: Any?
    let id: UUID = UUID()

    init(value: Any?) {
        self.value = value
    }

    func accept<V: Visitor>(_ visitor: V) throws -> Any? {
        return try visitor.visitLiteral(self)
    }

    static func == (lhs: Literal, rhs: Literal) -> Bool {
        return lhs.id == rhs.id
    }
}

class Unary: Declarations {
    let operator_: Token
    let right: any Declarations
    let id: UUID = UUID()

    init(operator_: Token, right: any Declarations) {
        self.operator_ = operator_
        self.right = right
    }

    func accept<V: Visitor>(_ visitor: V) throws -> Any? {
        return try visitor.visitUnary(self)
    }

    static func == (lhs: Unary, rhs: Unary) -> Bool {
        return lhs.id == rhs.id
    }
}

class Ternary: Declarations {
    let value1: Any?
    let op1: Token
    let value2: Any
    let op2: Token
    let value3: Any?
    let id: UUID = UUID()

    init(value1: Any?, op1: Token, value2: Any, op2: Token, value3: Any?) {
        self.value1 = value1
        self.op1 = op1
        self.value2 = value2
        self.op2 = op2
        self.value3 = value3
    }

    func accept<V: Visitor>(_ visitor: V) throws -> Any? {
        return try visitor.visitTernary(self)
    }

    static func == (lhs: Ternary, rhs: Ternary) -> Bool {
        return lhs.id == rhs.id
    }
}

class Block: Declarations {
    let statements: [any Declarations]
    let id: UUID = UUID()

    init(statements: [any Declarations]) {
        self.statements = statements
    }

    func accept<V: Visitor>(_ visitor: V) throws -> Any? {
        return try visitor.visitBlock(self)
    }

    static func == (lhs: Block, rhs: Block) -> Bool {
        return lhs.id == rhs.id
    }
}

class Expression: Declarations {
    let expression: any Declarations
    let id: UUID = UUID()

    init(expression: any Declarations) {
        self.expression = expression
    }

    func accept<V: Visitor>(_ visitor: V) throws -> Any? {
        return try visitor.visitExpression(self)
    }

    static func == (lhs: Expression, rhs: Expression) -> Bool {
        return lhs.id == rhs.id
    }
}

class Print: Declarations {
    let expression: any Declarations
    let id: UUID = UUID()

    init(expression: any Declarations) {
        self.expression = expression
    }

    func accept<V: Visitor>(_ visitor: V) throws -> Any? {
        return try visitor.visitPrint(self)
    }

    static func == (lhs: Print, rhs: Print) -> Bool {
        return lhs.id == rhs.id
    }
}

class Var: Declarations {
    let name: Token
    let initializer: any Declarations
    let id: UUID = UUID()

    init(name: Token, initializer: any Declarations) {
        self.name = name
        self.initializer = initializer
    }

    func accept<V: Visitor>(_ visitor: V) throws -> Any? {
        return try visitor.visitVar(self)
    }

    static func == (lhs: Var, rhs: Var) -> Bool {
        return lhs.id == rhs.id
    }
}

class Let: Declarations {
    let name: Token
    let intializer: any Declarations
    let id: UUID = UUID()

    init(name: Token, intializer: any Declarations) {
        self.name = name
        self.intializer = intializer
    }

    func accept<V: Visitor>(_ visitor: V) throws -> Any? {
        return try visitor.visitLet(self)
    }

    static func == (lhs: Let, rhs: Let) -> Bool {
        return lhs.id == rhs.id
    }
}

class Variable: Declarations {
    let name: Token
    let id: UUID = UUID()

    init(name: Token) {
        self.name = name
    }

    func accept<V: Visitor>(_ visitor: V) throws -> Any? {
        return try visitor.visitVariable(self)
    }

    static func == (lhs: Variable, rhs: Variable) -> Bool {
        return lhs.id == rhs.id
    }
}

class If: Declarations {
    let condition: any Declarations
    let thenBranch: any Declarations
    let elseBranch: (any Declarations)?
    let id: UUID = UUID()

    init(condition: any Declarations, thenBranch: any Declarations, elseBranch: (any Declarations)?) {
        self.condition = condition
        self.thenBranch = thenBranch
        self.elseBranch = elseBranch
    }

    func accept<V: Visitor>(_ visitor: V) throws -> Any? {
        return try visitor.visitIf(self)
    }

    static func == (lhs: If, rhs: If) -> Bool {
        return lhs.id == rhs.id
    }
}

class Assign: Declarations {
    let name: Token
    let value: any Declarations
    let id: UUID = UUID()

    init(name: Token, value: any Declarations) {
        self.name = name
        self.value = value
    }

    func accept<V: Visitor>(_ visitor: V) throws -> Any? {
        return try visitor.visitAssign(self)
    }

    static func == (lhs: Assign, rhs: Assign) -> Bool {
        return lhs.id == rhs.id
    }
}

class Logical: Declarations {
    let left: any Declarations
    let operator_: Token
    let right: any Declarations
    let id: UUID = UUID()

    init(left: any Declarations, operator_: Token, right: any Declarations) {
        self.left = left
        self.operator_ = operator_
        self.right = right
    }

    func accept<V: Visitor>(_ visitor: V) throws -> Any? {
        return try visitor.visitLogical(self)
    }

    static func == (lhs: Logical, rhs: Logical) -> Bool {
        return lhs.id == rhs.id
    }
}

class While: Declarations {
    let condition: any Declarations
    let body: any Declarations
    let id: UUID = UUID()

    init(condition: any Declarations, body: any Declarations) {
        self.condition = condition
        self.body = body
    }

    func accept<V: Visitor>(_ visitor: V) throws -> Any? {
        return try visitor.visitWhile(self)
    }

    static func == (lhs: While, rhs: While) -> Bool {
        return lhs.id == rhs.id
    }
}

class Break: Declarations {
    let level: Int
    let id: UUID = UUID()

    init(level: Int) {
        self.level = level
    }

    func accept<V: Visitor>(_ visitor: V) throws -> Any? {
        return try visitor.visitBreak(self)
    }

    static func == (lhs: Break, rhs: Break) -> Bool {
        return lhs.id == rhs.id
    }
}

class Call: Declarations {
    let calee: any Declarations
    let paren: Token
    let arguments: [any Declarations]
    let id: UUID = UUID()

    init(calee: any Declarations, paren: Token, arguments: [any Declarations]) {
        self.calee = calee
        self.paren = paren
        self.arguments = arguments
    }

    func accept<V: Visitor>(_ visitor: V) throws -> Any? {
        return try visitor.visitCall(self)
    }

    static func == (lhs: Call, rhs: Call) -> Bool {
        return lhs.id == rhs.id
    }
}

class Class: Declarations {
    let name: Token
    let methods: [FunctionDecl]
    let superclass: Variable?
    let id: UUID = UUID()

    init(name: Token, methods: [FunctionDecl], superclass: Variable?) {
        self.name = name
        self.methods = methods
        self.superclass = superclass
    }

    func accept<V: Visitor>(_ visitor: V) throws -> Any? {
        return try visitor.visitClass(self)
    }

    static func == (lhs: Class, rhs: Class) -> Bool {
        return lhs.id == rhs.id
    }
}

class Get: Declarations {
    let object: any Declarations
    let name: Token
    let id: UUID = UUID()

    init(object: any Declarations, name: Token) {
        self.object = object
        self.name = name
    }

    func accept<V: Visitor>(_ visitor: V) throws -> Any? {
        return try visitor.visitGet(self)
    }

    static func == (lhs: Get, rhs: Get) -> Bool {
        return lhs.id == rhs.id
    }
}

class Set_: Declarations {
    let object: any Declarations
    let name: Token
    let value: any Declarations
    let id: UUID = UUID()

    init(object: any Declarations, name: Token, value: any Declarations) {
        self.object = object
        self.name = name
        self.value = value
    }

    func accept<V: Visitor>(_ visitor: V) throws -> Any? {
        return try visitor.visitSet_(self)
    }

    static func == (lhs: Set_, rhs: Set_) -> Bool {
        return lhs.id == rhs.id
    }
}

class Super_: Declarations {
    let keyword: Token
    let method: Token
    let id: UUID = UUID()

    init(keyword: Token, method: Token) {
        self.keyword = keyword
        self.method = method
    }

    func accept<V: Visitor>(_ visitor: V) throws -> Any? {
        return try visitor.visitSuper_(self)
    }

    static func == (lhs: Super_, rhs: Super_) -> Bool {
        return lhs.id == rhs.id
    }
}

class This: Declarations {
    let keyword: Token
    let id: UUID = UUID()

    init(keyword: Token) {
        self.keyword = keyword
    }

    func accept<V: Visitor>(_ visitor: V) throws -> Any? {
        return try visitor.visitThis(self)
    }

    static func == (lhs: This, rhs: This) -> Bool {
        return lhs.id == rhs.id
    }
}

class FunctionDecl: Declarations {
    let name: Token
    let params: [Token]
    let body: [any Declarations]
    let id: UUID = UUID()

    init(name: Token, params: [Token], body: [any Declarations]) {
        self.name = name
        self.params = params
        self.body = body
    }

    func accept<V: Visitor>(_ visitor: V) throws -> Any? {
        return try visitor.visitFunctionDecl(self)
    }

    static func == (lhs: FunctionDecl, rhs: FunctionDecl) -> Bool {
        return lhs.id == rhs.id
    }
}

class Return: Declarations {
    let keyword: Token
    let value: any Declarations
    let level: Int
    let id: UUID = UUID()

    init(keyword: Token, value: any Declarations, level: Int) {
        self.keyword = keyword
        self.value = value
        self.level = level
    }

    func accept<V: Visitor>(_ visitor: V) throws -> Any? {
        return try visitor.visitReturn(self)
    }

    static func == (lhs: Return, rhs: Return) -> Bool {
        return lhs.id == rhs.id
    }
}

