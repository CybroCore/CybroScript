import Foundation

protocol Declarations {
    func accept<V: Visitor>(_ visitor: V) throws -> Any?
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
    func visitFunctionDecl(_ declarations: FunctionDecl) throws -> Any?
    func visitReturn(_ declarations: Return) throws -> Any?
}

class Binary: Declarations {
    let left: Declarations
    let operator_: Token
    let right: Declarations

    init(left: Declarations, operator_: Token, right: Declarations) {
        self.left = left
        self.operator_ = operator_
        self.right = right
    }

    func accept<V: Visitor>(_ visitor: V) throws -> Any? {
        return try visitor.visitBinary(self)
    }
}

class Grouping: Declarations {
    let expression: Declarations

    init(expression: Declarations) {
        self.expression = expression
    }

    func accept<V: Visitor>(_ visitor: V) throws -> Any? {
        return try visitor.visitGrouping(self)
    }
}

class Literal: Declarations {
    let value: Any?

    init(value: Any?) {
        self.value = value
    }

    func accept<V: Visitor>(_ visitor: V) throws -> Any? {
        return try visitor.visitLiteral(self)
    }
}

class Unary: Declarations {
    let operator_: Token
    let right: Declarations

    init(operator_: Token, right: Declarations) {
        self.operator_ = operator_
        self.right = right
    }

    func accept<V: Visitor>(_ visitor: V) throws -> Any? {
        return try visitor.visitUnary(self)
    }
}

class Ternary: Declarations {
    let value1: Any?
    let op1: Token
    let value2: Any
    let op2: Token
    let value3: Any?

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
}

class Block: Declarations {
    let statements: [Declarations]

    init(statements: [Declarations]) {
        self.statements = statements
    }

    func accept<V: Visitor>(_ visitor: V) throws -> Any? {
        return try visitor.visitBlock(self)
    }
}

class Expression: Declarations {
    let expression: Declarations

    init(expression: Declarations) {
        self.expression = expression
    }

    func accept<V: Visitor>(_ visitor: V) throws -> Any? {
        return try visitor.visitExpression(self)
    }
}

class Print: Declarations {
    let expression: Declarations

    init(expression: Declarations) {
        self.expression = expression
    }

    func accept<V: Visitor>(_ visitor: V) throws -> Any? {
        return try visitor.visitPrint(self)
    }
}

class Var: Declarations {
    let name: Token
    let initializer: Declarations

    init(name: Token, initializer: Declarations) {
        self.name = name
        self.initializer = initializer
    }

    func accept<V: Visitor>(_ visitor: V) throws -> Any? {
        return try visitor.visitVar(self)
    }
}

class Let: Declarations {
    let name: Token
    let intializer: Declarations

    init(name: Token, intializer: Declarations) {
        self.name = name
        self.intializer = intializer
    }

    func accept<V: Visitor>(_ visitor: V) throws -> Any? {
        return try visitor.visitLet(self)
    }
}

class Variable: Declarations {
    let name: Token

    init(name: Token) {
        self.name = name
    }

    func accept<V: Visitor>(_ visitor: V) throws -> Any? {
        return try visitor.visitVariable(self)
    }
}

class If: Declarations {
    let condition: Declarations
    let thenBranch: Declarations
    let elseBranch: Declarations?

    init(condition: Declarations, thenBranch: Declarations, elseBranch: Declarations?) {
        self.condition = condition
        self.thenBranch = thenBranch
        self.elseBranch = elseBranch
    }

    func accept<V: Visitor>(_ visitor: V) throws -> Any? {
        return try visitor.visitIf(self)
    }
}

class Assign: Declarations {
    let name: Token
    let value: Declarations

    init(name: Token, value: Declarations) {
        self.name = name
        self.value = value
    }

    func accept<V: Visitor>(_ visitor: V) throws -> Any? {
        return try visitor.visitAssign(self)
    }
}

class Logical: Declarations {
    let left: Declarations
    let operator_: Token
    let right: Declarations

    init(left: Declarations, operator_: Token, right: Declarations) {
        self.left = left
        self.operator_ = operator_
        self.right = right
    }

    func accept<V: Visitor>(_ visitor: V) throws -> Any? {
        return try visitor.visitLogical(self)
    }
}

class While: Declarations {
    let condition: Declarations
    let body: Declarations

    init(condition: Declarations, body: Declarations) {
        self.condition = condition
        self.body = body
    }

    func accept<V: Visitor>(_ visitor: V) throws -> Any? {
        return try visitor.visitWhile(self)
    }
}

class Break: Declarations {
    let level: Int

    init(level: Int) {
        self.level = level
    }

    func accept<V: Visitor>(_ visitor: V) throws -> Any? {
        return try visitor.visitBreak(self)
    }
}

class Call: Declarations {
    let calee: Declarations
    let paren: Token
    let arguments: [Declarations]

    init(calee: Declarations, paren: Token, arguments: [Declarations]) {
        self.calee = calee
        self.paren = paren
        self.arguments = arguments
    }

    func accept<V: Visitor>(_ visitor: V) throws -> Any? {
        return try visitor.visitCall(self)
    }
}

class FunctionDecl: Declarations {
    let name: Token
    let params: [Token]
    let body: [Declarations]

    init(name: Token, params: [Token], body: [Declarations]) {
        self.name = name
        self.params = params
        self.body = body
    }

    func accept<V: Visitor>(_ visitor: V) throws -> Any? {
        return try visitor.visitFunctionDecl(self)
    }
}

class Return: Declarations {
    let keyword: Token
    let value: Declarations
    let level: Int

    init(keyword: Token, value: Declarations, level: Int) {
        self.keyword = keyword
        self.value = value
        self.level = level
    }

    func accept<V: Visitor>(_ visitor: V) throws -> Any? {
        return try visitor.visitReturn(self)
    }
}

