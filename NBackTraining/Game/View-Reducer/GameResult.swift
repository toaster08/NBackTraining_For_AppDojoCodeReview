import SwiftUI

import ComposableArchitecture
import Dependencies
import Lottie

struct GameResultView: View {
    let store: StoreOf<GameResult>
    let viewStore: ViewStoreOf<GameResult>
    init(store: StoreOf<GameResult>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        ZStack {
            LottieView(
                name: viewStore.evaluation.animationName,
                loopMode: .loop
            )
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            
            VStack(spacing: 20) {
                Text("\(viewStore.resultValue)%")
                    .font(.title3)
                    .foregroundColor(.black)
                
                Text(viewStore.evaluation.resultMessage)
                    .font(.title3)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                
                Button("OK") {
                    viewStore.send(.delegate(.didTapOkAction))
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }

        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 10)
    }
}

@Reducer
struct GameResult {
    @ObservableState
    struct State: Equatable {
        var evaluation: Evaluation = .noChange(result: 70)
        
        var resultValue: Int {
            return switch evaluation {
            case .up(let result): result
            case .noChange(let result): result
            case .down(let result): result
            }
        }
        
        mutating func updateResult(result: Evaluation) -> Effect<Action> {
            .run { send in await send(.updateResult(result)) }
        }
    }
    
    enum Action {
        case updateResult(Evaluation)
        case delegate(Delegate)
        enum Delegate {
            case didTapOkAction // FIXME: rename
        }
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .updateResult(result):
                state.evaluation = result
                return .none
            default:
                return .none
            }
        }
    }
}

fileprivate extension Evaluation {
    var resultMessage: String {
        return switch self {
        case .up: "レベルアップ。いいですね、その調子です。"
        case .noChange: "いまのCountで続けていきましょう"
        case .down: "少し調子が悪いみたいです、レベルを下げてみましょう。"
        }
    }
    
    var animationName: String {
        return switch self {
        case .up: "99718-confetti-animation"
        case .noChange: "99718-confetti-animation"
        case .down: "99718-confetti-animation"
        }
    }
}

