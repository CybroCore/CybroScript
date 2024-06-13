import Foundation


struct Interpreter_: Visitor {
    typealias ReturnType = Any?

    func visitLiteral(_ expr: Literal) -> Any? {
        return expr.value
    }

    func visitGrouping(_ expr: Grouping) -> Any? {
        return evaluate(expr: expr.expression)
    }

    func evaluate(expr: Expr) -> Any? {
        return expr.accept(self)
    }

    func visitUnary(_ expr: Unary) -> Any? {
        let right = evaluate(expr: expr.right)

        switch expr.operator_.type {
        case .MINUS:
            if let number = right as? Double {
                return -number
            } else if let number = Double("\(right ?? "")") {
                return -number
            } else {
                return nil
            }

        case .BANG:
            if let value = right as? Bool {
                return !value
            } else if let value = right as? String {
                if ["FALSE", "false", "False"].contains(value) {
                    return false
                } else if ["TRUE", "true", "True"].contains(value) {
                    return true
                }
                return value.count > 0 ? true : false
            } else if right == nil {
                return false
            } else if let value = right as? Double {
                return value == 0 ? false : true
            }
            return true
        default:
            return nil
        }

    }

    func visitBinary(_ expr: Binary) -> Any? {
        let left = evaluate(expr: expr.left);
        let right = evaluate(expr: expr.right);
        
            switch expr.operator_.type {
            case .MINUS:
                if let value = right as? Double, let value2 = left as? Double {
                    return value2 - value;
                }
            case .SLASH:
                if let value = right as? Double, let value2 = left as? Double {
                    return value2 / value;
                }
            case .STAR:
                if let value = right as? Double, let value2 = left as? Double {
                    return value2 * value;
                }
            case .PLUS:
                if let value2 = right as? Double, let value1 = left as? Double {
                    return value1 + value2
                } else {
                    return "\(left ?? "nil")\(right ?? "nil")"
                }
            case .GREATER:
                if let value2 = right as? Double, let value1 = left as? Double {
                    return value1 > value2;
                }
            case .GREATER_EQUAL:
                if let value2 = right as? Double, let value1 = left as? Double {
                    return value1 >= value2;
                }
            case .LESS:
                if let value2 = right as? Double, let value1 = left as? Double {
                    return value1 < value2;
                }
            case .LESS_EQUAL:
                if let value2 = right as? Double, let value1 = left as? Double {
                    return value1 <= value2
                }
            case .EQUAL_EQUAL:
                if right == nil && left == nil {
                    return true
                }
                if left == nil {
                    return false
                }
                if "\(left ?? "nil")" == "\(right ?? "nil")" {
                    return true
                }
                
            default:
                return nil
        }

        return nil;
}
    
    func interpret(expression_: Expr) {
        let value = evaluate(expr: expression_);
        print("\(value ?? "nil")");
      }
}
