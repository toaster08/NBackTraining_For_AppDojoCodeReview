import SwiftUI

import ComposableArchitecture
import Dependencies

@Reducer
struct GameStartPreparation {
    static let totalRepeats: Int = 3
    
    @ObservableState
    struct State: Equatable {
        var progress: CGFloat = 0
        var repeatCount: Int = 0
    }
    
    enum Action {
        case view(ViewAction)
        case `internal`(InternalAction)
        case delegate(Delegate)

        enum ViewAction {
            case onAppear
        }
        
        enum InternalAction {
            case repeatCountDown
            case countDown
            case resetProgress
            case decrementCount
        }
        
        enum Delegate {
            case endPreparation
        }
    }
    
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.continuousClock) var clock
    let generator = UINotificationFeedbackGenerator()

    private enum CancelID { case timer }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                switch viewAction {
                case .onAppear:
                    return start(&state)
                }
                
            case let .internal(internalAction):
                switch internalAction {
                case .repeatCountDown:
                    return .run { send in
                        for _ in 1...(Self.totalRepeats) {
                            await send(.internal(.resetProgress))
                            await send(.internal(.countDown), animation: .linear(duration: 1.0))
                            try await self.clock.sleep(for: .seconds(1))
                            await send(.internal(.decrementCount))
                        }
                        
                        try await self.clock.sleep(for: .seconds(1))
                        await send(.delegate(.endPreparation))
                    }
                    .cancellable(id: CancelID.timer)
                case .countDown:
                    return repeatCountDown(&state)
                case .resetProgress:
                    state.progress = 0
                    return .none
                case .decrementCount:
                    generator.notificationOccurred(.success)
                    state.repeatCount -= 1
                    return .none
                }
            case .delegate:
                return .none
            }
        }
    }
    
    func start(_ state: inout State) -> Effect<Action> {
        state.repeatCount = 3
        return .run { send in
            try await self.clock.sleep(for: .seconds(1))
            await send(.internal(.repeatCountDown))
        }
    }
    
    func repeatCountDown(_ state: inout State) -> Effect<Action> {
        state.progress = 1
        return .none
    }
}

struct GameStartPreparationView: View {
    static let circleSize: CGSize = .init(width: 200, height: 200)
    static let degrees: Double = -90
    
    let viewStore: ViewStoreOf<GameStartPreparation>
    init(store: StoreOf<GameStartPreparation>) {
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        ZStack {
            Circle()
                .frame(
                    width: Self.circleSize.width,
                    height: Self.circleSize.height
                )
                .foregroundColor(.white)
                .rotationEffect(Angle(degrees: Self.degrees))
            Circle()
                .trim(from: viewStore.progress, to: 1)
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .frame(
                    width: Self.circleSize.width,
                    height: Self.circleSize.height
                )
                .rotationEffect(Angle(degrees: Self.degrees))
            countTitle
                .font(.largeTitle)
                .bold()
        }
        .onAppear {
            viewStore.send(.view(.onAppear))
        }
    }
    
    var countTitle: some View {
        if viewStore.repeatCount > 0 {
            Text("\(viewStore.repeatCount)")
        } else {
            Text("スタート")
        }
    }
}
