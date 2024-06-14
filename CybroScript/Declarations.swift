import Foundation

protocol Declarations {
    func accept<V: Visitor>(_ visitor: V) -> Any?
}

protocol Visitor {
    func visitBinary(_ declarations: Binary) -> Any?
    func visitGrouping(_ declarations: Grouping) -> Any?
    func visitLiteral(_ declarations: Literal) -> Any?
    func visitUnary(_ declarations: Unary) -> Any?
    func visitTernary(_ declarations: Ternary) -> Any?
    func visitExpression(_ declarations: Expression) -> Any?
    func visitPrint(_ declarations: Print) -> Any?
    func visitVar(_ declarations: Var) -> Any?
    func visitLet(_ declarations: Let) -> Any?
    func visitVariable(_ declarations: Variable) -> Any?
    func visitAssign(_ declarations: Assign) -> Any?
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

    func accept<V: Visitor>(_ visitor: V) -> Any? {
        return visitor.visitBinary(self)
    }
}

class Grouping: Declarations {
    let expression: Declarations

    init(expression: Declarations) {
        self.expression = expression
    }

    func accept<V: Visitor>(_ visitor: V) -> Any? {
        return visitor.visitGrouping(self)
    }
}

class Literal: Declarations {
    let value: Any?

    init(value: Any?) {
        self.value = value
    }

    func accept<V: Visitor>(_ visitor: V) -> Any? {
        return visitor.visitLiteral(self)
    }
}

class Unary: Declarations {
    let operator_: Token
    let right: Declarations

    init(operator_: Token, right: Declarations) {
        self.operator_ = operator_
        self.right = right
    }

    func accept<V: Visitor>(_ visitor: V) -> Any? {
        return visitor.visitUnary(self)
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

    func accept<V: Visitor>(_ visitor: V) -> Any? {
        return visitor.visitTernary(self)
    }
}

class Expression: Declarations {
    let expression: Declarations

    init(expression: Declarations) {
        self.expression = expression
    }

    func accept<V: Visitor>(_ visitor: V) -> Any? {
        return visitor.visitExpression(self)
    }
}

class Print: Declarations {
    let expression: Declarations

    init(expression: Declarations) {
        self.expression = expression
    }

    func accept<V: Visitor>(_ visitor: V) -> Any? {
        return visitor.visitPrint(self)
    }
}

class Var: Declarations {
    let name: Token
    let initializer: Declarations

    init(name: Token, initializer: Declarations) {
        self.name = name
        self.initializer = initializer
    }

    func accept<V: Visitor>(_ visitor: V) -> Any? {
        return visitor.visitVar(self)
    }
}

class Let: Declarations {
    let name: Token
    let intializer: Declarations

    init(name: Token, intializer: Declarations) {
        self.name = name
        self.intializer = intializer
    }

    func accept<V: Visitor>(_ visitor: V) -> Any? {
        return visitor.visitLet(self)
    }
}

class Variable: Declarations {
    let name: Token

    init(name: Token) {
        self.name = name
    }

    func accept<V: Visitor>(_ visitor: V) -> Any? {
        return visitor.visitVariable(self)
    }
}

class Assign: Declarations {
    let name: Token
    let value: Declarations

    init(name: Token, value: Declarations) {
        self.name = name
        self.value = value
    }

    func accept<V: Visitor>(_ visitor: V) -> Any? {
        return visitor.visitAssign(self)
    }
}


