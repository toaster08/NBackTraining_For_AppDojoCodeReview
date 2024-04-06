import Foundation

struct Problem: Equatable {
    enum Expression: Int, CaseIterable, Equatable {
        case add = 0
        case subtract
        
        var string: String {
            switch self {
            case .add: return "+"
            case .subtract: return "-"
            }
        }
        
        var calculatedValue: (Int, Int) -> Int {
            switch self {
            case .add: (+)
            case .subtract: (-)
            }
        }
        
        static var random: Self {
            Self.allCases.randomElement()!
        }
    }
    
    private let expression: Expression
    private let lhsNumber: Int
    private let rhsNumber: Int
    
    var totalNumber: Int {
        expression.calculatedValue(lhsNumber, rhsNumber)
    }
    
    var expressionString: String {
        "\(lhsNumber) \(expression.string) \(rhsNumber)"
    }
    
    init() {
        let expression = Expression.random
        let leftSideNumber = Int.random(in: 1...9)
        let rightSideNumber: Int = {
            switch expression {
            case .add:
                let rhsUpperNumber = 9 - leftSideNumber
                let rhsNumber = Int.random(in: 0...rhsUpperNumber)
                return rhsNumber
            case .subtract:
                let rhsUpperNumber = leftSideNumber - 1
                let rhsNumber = Int.random(in: 0...rhsUpperNumber)
                return rhsNumber
            }
        }()
        
        self.expression = expression
        self.lhsNumber = leftSideNumber
        self.rhsNumber = rightSideNumber
    }
}
