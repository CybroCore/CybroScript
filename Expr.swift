import Foundation

protocol Expr {}

class Binary: Expr {
    let left: Expr
    let operator_: Token
    let right: Expr

    init(left: Expr, operator_: Token, right: Expr) {
        self.Expr = Expr
        self.Token = Token
        self.Expr = Expr
    }
}

class Grouping: Expr {
    let expression: Expr

    init(expression: Expr) {
        self.Expr = Expr
    }
}

class Literal: Expr {
    let value: Any?

    init(value: Any?) {
        self.Any? = Any?
    }
}

class Unary: Expr {
    let operator_: Token
    let right: Expr

    init(operator_: Token, right: Expr) {
        self.Token = Token
        self.Expr = Expr
    }
}

