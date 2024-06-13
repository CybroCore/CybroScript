import Foundation

protocol Expr {
    func accept<V: Visitor>(_ visitor: V) -> Any?
}

protocol Visitor {
    func visitBinary(_ expr: Binary) -> Any?
    func visitGrouping(_ expr: Grouping) -> Any?
    func visitLiteral(_ expr: Literal) -> Any?
    func visitUnary(_ expr: Unary) -> Any?
}

class Binary: Expr {
    let left: Expr
    let operator_: Token
    let right: Expr

    init(left: Expr, operator_: Token, right: Expr) {
        self.left = left
        self.operator_ = operator_
        self.right = right
    }

    func accept<V: Visitor>(_ visitor: V) -> Any? {
        return visitor.visitBinary(self)
    }
}

class Grouping: Expr {
    let expression: Expr

    init(expression: Expr) {
        self.expression = expression
    }

    func accept<V: Visitor>(_ visitor: V) -> Any? {
        return visitor.visitGrouping(self)
    }
}

class Literal: Expr {
    let value: Any?

    init(value: Any?) {
        self.value = value
    }

    func accept<V: Visitor>(_ visitor: V) -> Any? {
        return visitor.visitLiteral(self)
    }
}

class Unary: Expr {
    let operator_: Token
    let right: Expr

    init(operator_: Token, right: Expr) {
        self.operator_ = operator_
        self.right = right
    }

    func accept<V: Visitor>(_ visitor: V) -> Any? {
        return visitor.visitUnary(self)
    }
}
