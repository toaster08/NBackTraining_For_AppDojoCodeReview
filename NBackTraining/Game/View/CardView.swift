import SwiftUI

struct CardView: View {
    enum CardType {
        case answer
        case question
    }
    
    let cardType: CardType
    let expression: Problem?
    
    var body: some View {
        Text(expression?.expressionString ?? "")
            .font(.title)
            .frame(maxWidth: .infinity, minHeight: 100)
            .roundedRectangleBorder(.white, width: 1, radius: 10, background: .white)
    }
}

