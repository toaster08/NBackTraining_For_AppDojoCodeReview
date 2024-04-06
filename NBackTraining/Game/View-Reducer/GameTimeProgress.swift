import SwiftUI

import ComposableArchitecture
import Dependencies

@Reducer
struct GameTimeProgress {
    static let totalTime: CGFloat = 5

    @ObservableState
    struct State: Equatable {
        var elapsedTime: CGFloat = GameTimeProgress.totalTime
        var isTimerActive: Bool = false
        
        mutating func startTimer() -> Effect<GameTimeProgress.Action> {
            return .send(.startTimer)
        }
        mutating func stopTimer() -> Effect<GameTimeProgress.Action> {
            return .send(.stopTimer)
        }
    }
    
    enum Action {
        // ui
        case onDisappear
        // internal
        case startTimer
        case erapsedTime
        case stopTimer
        
        case delegate(Delegate)
        enum Delegate {
            case timeOver
        }
    }
    
    @Dependency(\.continuousClock) var clock
    private enum CancelID { case timer }
    
    public var body: some ReducerOf<Self> {
        Reduce {
            state,
            action in
            switch action {
            case .onDisappear:
                return .send(.stopTimer)
                
            case .startTimer:
                state.isTimerActive = true
                state.elapsedTime = Self.totalTime
                
                return .run { [state] send in
                    guard state.isTimerActive, state.elapsedTime > 0 else {
                        return await send(.stopTimer)
                    }
                    
                    for await _ in self.clock.timer(interval: .seconds(0.01)) {
                        await send(.erapsedTime)
                    }
                }
                .cancellable(
                    id: CancelID.timer,
                    cancelInFlight: true
                )
            
            case .erapsedTime:
                if state.elapsedTime <= 0 {
                    return .concatenate([
                        .send(.delegate(.timeOver)),
                        .send(.stopTimer)
                    ])
                } else {
                    state.elapsedTime -= 0.01
                    return .none
                }

            case .stopTimer:
                state.isTimerActive = false
                return .cancel(id: CancelID.timer)
                
            case .delegate:
                return .none
            default:
                return .none
            }
        }
    }
}

struct GameTimeProgressView: View {
    let store: StoreOf<GameTimeProgress>
    let viewStore: ViewStoreOf<GameTimeProgress>
    init(store: StoreOf<GameTimeProgress>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        HStack {
            Image(systemName: "timer")
            ProgressView(
                value: viewStore.elapsedTime,
                total: GameTimeProgress.totalTime
            )
            .progressViewStyle(LinearProgressViewStyle())
            .frame(maxWidth: .infinity, maxHeight: 20)
            .onDisappear {
                viewStore.send(.onDisappear)
            }
        }
    }
}


