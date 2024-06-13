import Foundation

struct AstPrinter {
    static func print(_ expr: Expr) -> String {
        if let expr = expr as? Binary {
            return parenthesize(expr.operator_.lexeme, expr.left, expr.right)
        }
        if let expr = expr as? Grouping {
            return parenthesize("group", expr.expression)
        }
        if let expr = expr as? Literal {
            return expr.value == nil ? "nil" : "\(expr.value!)"
        }
        if let expr = expr as? Unary {
            return parenthesize(expr.operator_.lexeme, expr.right)
        }
        return ""
    }

    static func parenthesize(_ name: String, _ exprs: Expr...) -> String {
        var result = "(" + name
        for expr in exprs {
            result += " " + AstPrinter.print(expr)
        }
        result += ")"
        return result
    }
}

func runPrinter() {
    print(AstPrinter.print(Binary(
        left: Unary(
            operator_: Token(type: .MINUS, lexeme: "-", literal: nil, line: 1),
            right: Literal(value: 123)
        ),
        operator_: Token(type: .STAR, lexeme: "*", literal: nil, line: 1),
        right: Grouping(expression: Literal(value: 45.67))
    )
    )
    )
}
