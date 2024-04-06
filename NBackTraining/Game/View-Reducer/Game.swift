import SwiftUI
import PencilKit
import Vision
import CoreML

import ComposableArchitecture

@Reducer
struct Game {
    @ObservableState
    struct State: Equatable {
        // child
        var timeProgressReducer: GameTimeProgress.State
        var startPreparationReducer: GameStartPreparation.State
        var resultReducer: GameResult.State
        
        var nBackCountLevel: Int = 3
        var gameState: GameState = .notPlay
        // list
        var memorizeProblemList: [Problem]? = nil
        var answerProblemList: [Problem]? = nil
        var answerResultList: [Answer] = []
        var hasNextProblem: Bool {
            guard let answerProblemList else { return false }
            return !answerProblemList.isEmpty
        }
        
        // ui
        var currentMemorizeProblem: Problem? = nil
        var currentAnswerProblem: Problem? = nil
        var isCorrect: Bool?
        
        // drawing
        var recognizedNumber: Int? = nil
        var drawingImage: Image? = nil
        var isDrawing: Bool = false
    }
    
    enum Action {
        // child
        case timeProgressReducer(GameTimeProgress.Action)
        case startPreparationReducer(GameStartPreparation.Action)
        case resultReducer(GameResult.Action)
        
        case view(ViewAction)
        case `internal`(InternalAction)
        
        enum ViewAction {
            case onAppear
            case didTapStartButton
            case didDrawingCanvas(PKCanvasView)
            case didTapResetCanvasView
        }
        
        enum InternalAction {
            case gameStart
            case stepNext
            case gameEnd
            
            case recognizeAnswer(Int?)
            case receivedError(GameError)
        }
    }
    
    private let useCase: GameUseCase
    @Dependency(\.userSettingRepository) var repository
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.continuousClock) var clock

    enum CancelID { case drawing }
    init(useCase: GameUseCase) {
        self.useCase = useCase
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.timeProgressReducer, action: \.timeProgressReducer) {
            GameTimeProgress()
        }
        Scope(state: \.startPreparationReducer, action: \.startPreparationReducer) {
            GameStartPreparation()
        }
        Scope(state: \.resultReducer, action: \.resultReducer) {
            GameResult()
        }
        
        Reduce { state, action in
            switch action {
            // child action
            case let .startPreparationReducer(.delegate(action)):
                switch action {
                case .endPreparation:
                    return .send(.internal(.gameStart))
                }
            case let .timeProgressReducer(.delegate(action)):
                switch action {
                case .timeOver:
                    state.answerResultList.append(.incorrect)
                    return .concatenate([
                        .cancel(id: CancelID.drawing),
                        .send(.internal(.stepNext))
                    ])
                }
            case let .resultReducer(.delegate(action)):
                switch action {
                case .didTapOkAction:
                    state.gameState = .notPlay
                    return .none
                }

            case let .view(action):
                return handleViewAction(&state, action: action)
                
            case let .internal(action):
                return handleInternalAction(&state, action: action)
            
            default:
                return .none
            }
        }
    }
}

// handle action
extension Game {
    func handleViewAction(_ state: inout State, action: Game.Action.ViewAction) -> Effect<Action> {
        switch action {
        case .onAppear:
            state.nBackCountLevel =  3
            return .none
        
        case .didTapStartButton:
            state.gameState = .start
            return .none
            
        case let .didDrawingCanvas(canvas):
            let inputImage = canvas.drawing.image(from: canvas.bounds, scale: 1)
            state.isDrawing = true
            return recognize(&state, inputImage: inputImage)
                .debounce(
                    id: CancelID.drawing,
                    for: 0.5,
                    scheduler: mainQueue
                )
                .cancellable(id: CancelID.drawing)
        
        case .didTapResetCanvasView:
            state.recognizedNumber = nil
            state.drawingImage = nil
            return .none
        }
    }
    
    func handleInternalAction(_ state: inout State, action: Game.Action.InternalAction) -> Effect<Action> {
        switch action {
        case let .recognizeAnswer(number):
            return recognizedAnswer(&state, number: number)
        case let .receivedError(error):
            // FIXME: error handling
            return .none
        case .gameStart:
            stepToStartInitially(&state)
            return state.timeProgressReducer.startTimer()
                .map(Action.timeProgressReducer)
        
        case .stepNext:
            return stepNextProblem(&state)
        
        case .gameEnd:
            do {
                reset(&state)
                let percentage = try useCase.getAnswerPercentage(from: state.answerResultList)
                let grade = useCase.getResultGrading(percentage)
                let nBackCount = useCase.updateNBackCountLevel(grade, currentLevel: state.nBackCountLevel)
                _ = state.resultReducer.updateResult(result: grade)
                state.gameState = .gameEnd(nBackCount: nBackCount)
                return .none
            } catch {
                return .send(.internal(.receivedError(error as! GameError)))
            }
        }
    }
}

extension Game {
    func recognizedAnswer(_ state: inout State, number: Int?) -> Effect<Action> {
        state.recognizedNumber = number
        state.isDrawing = false

        if let number, let currentProblem = state.currentAnswerProblem {
            let result = useCase.answeredWithInTime(number, for: currentProblem)
            if result == .correct {
                state.isCorrect = true
                state.answerResultList.append(result)
                return .concatenate([
                    state.timeProgressReducer.stopTimer()
                        .map(Action.timeProgressReducer),
                    .cancel(id: CancelID.drawing),
                    .send(.internal(.stepNext))
                ])
            } else {
                state.isCorrect = false
            }
        }
        
        return .none
    }
    
    func stepNextProblem(_ state: inout State) -> Effect<Action>{
        changePlaingState(&state)
        reset(&state)
        
        switch state.gameState {
        case let .playing(state: playingState):
            switch playingState {
            case .memorizeOnly:
                setMemorizeProblem(&state)
                return state.timeProgressReducer.startTimer()
                    .map(Action.timeProgressReducer)
            case .memorizeAndAnswer:
                setMemorizeProblem(&state)
                setAnswerProblem(&state)
                return state.timeProgressReducer.startTimer()
                    .map(Action.timeProgressReducer)
            case .answerOnly:
                if state.hasNextProblem {
                    setAnswerProblem(&state)
                    return state.timeProgressReducer.startTimer()
                        .map(Action.timeProgressReducer)
                } else {
                    return .send(.internal(.gameEnd))
                }
            }
        default:
            // FIXME: error handling
            return .send(.internal(.receivedError(.unknown)))
        }
    }
    
    // FIXME: Testしたい
    func changePlaingState(_ state: inout State) {
        guard let memorizeList = state.memorizeProblemList else { return }
        guard let answerList = state.answerProblemList else { return }
        
        if !memorizeList.isEmpty, answerList.isEmpty {
            state.gameState = .playing(state: .memorizeOnly)
        }
        if answerList.count > state.nBackCountLevel {
            state.gameState = .playing(state: .memorizeAndAnswer)
        }
        if memorizeList.isEmpty, !answerList.isEmpty {
            state.gameState = .playing(state: .answerOnly)
        }
    }
    
    func stepToStartInitially(_ state: inout State) {
        state.gameState = .playing(state: .memorizeOnly)
        state.memorizeProblemList = useCase.generateProblemList()
        state.answerProblemList = []
        setMemorizeProblem(&state)
    }
    
    func setMemorizeProblem(_ state: inout State)  {
        guard let curretProblem = state.memorizeProblemList?.first else { return }
        state.memorizeProblemList?.removeFirst()
        state.currentMemorizeProblem = curretProblem
        state.answerProblemList?.append(curretProblem)
    }
    
    func setAnswerProblem(_ state: inout State) {
        guard let curretProblem = state.answerProblemList?.first else { return }
        state.answerProblemList?.removeFirst()
        state.currentAnswerProblem = curretProblem
    }
    
    func reset(_ state: inout State) {
        state.recognizedNumber = nil
        state.drawingImage = nil
        state.isCorrect = nil
        state.currentMemorizeProblem = nil
        state.currentAnswerProblem = nil
    }
    
    func recognize(_ state: inout State, inputImage: UIImage) -> Effect<Action> {
        return .run { send in
            do {
                let results = try await performVisionRequest(inputImage)
                let recognizedNumber = results.first?.identifier.toInt()
                await send(.internal(.recognizeAnswer(recognizedNumber)))
            } catch {
                // FIXME: エラーハンドリング
                await send(.internal(.receivedError(.unknown)))
            }
        }
    }
    
    func performVisionRequest(_ image: UIImage) async throws -> [VNClassificationObservation] {
        let model =  try! VNCoreMLModel(for: MNISTClassifier.init(configuration: .init()).model)
        let handler = VNImageRequestHandler(cgImage: image.cgImage!)

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNCoreMLRequest(model: model) { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let results = request.results as? [VNClassificationObservation] else {
                    continuation.resume(throwing: GameError.unknown)
                    return
                }
                continuation.resume(returning: results)
            }
            request.usesCPUOnly = true
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
