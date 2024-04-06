import SwiftUI
import PencilKit
import Vision
import CoreML

import ComposableArchitecture

struct GameView: View {
    let canvasView: CanvasView = .init(canvas: PKCanvasView())
    @State private var isPresented: Bool = false
    
    let store: StoreOf<Game>
    let viewStore: ViewStoreOf<Game>
    init(store: StoreOf<Game>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        GeometryReader { geo in
            NavigationStack {
                ZStack {
                    VStack(spacing: 20) {
                        GameTimeProgressView(
                            store: store.scope(
                                state: \.timeProgressReducer,
                                action: \.timeProgressReducer
                            )
                        )
                        VStack(spacing: 15) {
                            CardView(
                                cardType: .question,
                                expression: store.state.currentMemorizeProblem
                            )
                            ZStack(alignment: .topTrailing) {
                                CardView(
                                    cardType: .answer,
                                    expression: store.state.currentAnswerProblem
                                )
                                answerImage
                                    .padding(.vertical)
                                    .padding(.trailing, 20)
                            }
                        }
                        
                        switch store.gameState {
                        case .notPlay, .start:
                            VStack(spacing: 30) {
                                Spacer()
                                startButton
                                ruleDescriptionButton
                            }
                            Spacer()
                        case .playing:
                            VStack {
                                GeometryReader { geo in
                                    ZStack {
                                        writingModeView
                                            .disabled(!viewStore.gameState.isAnswerable)
                                        if !viewStore.gameState.isAnswerable {
                                            Color.gray
                                                .opacity(0.5)
                                                .frame(
                                                    width: geo.frame(in: .local).width,
                                                    height: geo.frame(in: .local).height
                                                )
                                            Text("覚えて")
                                                .foregroundStyle(.white)
                                                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                                        }
                                    }
                                }
                                canvasAnswerButton
                                    .disabled(!viewStore.gameState.isAnswerable)
                            }
                        case let .gameEnd(nBackCount):
                            // FIXME: if let storeで書き換える
                            GameResultView(store:
                                        store.scope(
                                            state: \.resultReducer,
                                            action: \.resultReducer
                                        )
                            )
                        }
                    }
                    .padding()
                    
                    switch store.gameState {
                    case .start:
                        ZStack {
                            Color.black
                                .ignoresSafeArea()
                                .opacity(0.3)
                                .frame(
                                    width: geo.frame(in: .global).width,
                                    height: geo.frame(in: .global).height
                                )
                            GameStartPreparationView(
                                store: store.scope(
                                    state: \.startPreparationReducer,
                                    action: \.startPreparationReducer
                                )
                            )
                        }
                    default:
                        EmptyView()
                    }
                }
            }
        }
    }
    
    private var answerImage: some View {
        VStack(spacing: 10) {
            Image(systemName: "circle")
                .foregroundColor(
                    viewStore.isCorrect == true ? .green : .gray
                )
                .bold()
            Image(systemName: "multiply")
                .foregroundColor(
                    viewStore.isCorrect == false ? .red : .gray
                )
                .bold()
        }
    }
    
    private var startButton: some View {
        Button(action: {
            canvasView.reset()
            store.send(.view(.didTapStartButton), animation: .easeIn)
        }, label: {
            BevelCircle(buttonTitle: "遊ぶ", size: .init(width: 100, height: 100))
        })
        .frame(alignment: .center)
    }
    
    private var ruleDescriptionButton: some View {
        Button(action: {
            isPresented = true
        }, label: {
            Text("ルール")
                .frame(width: 200, height: 50)
                .background(.blue)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 1)
                        .fill(.blue)
                }
                .mask {
                    RoundedRectangle(cornerRadius: 10)
                }
                .foregroundStyle(.white)
                .padding(.top)
        })
        .padding(.bottom)
        .sheet(isPresented: $isPresented) {
            GameRuleView()
        }
    }
    
    private var writingModeView: some View {
        ZStack(alignment: .top) {
            canvasView
                .frame(maxWidth: .infinity, minHeight: 100)
                .roundedRectangleBorder(
                    .white,
                    width: 1,
                    radius: 10,
                    background: .white
                )
                .overlay {
                    GeometryReader { proxy in
                        if let num = store.recognizedNumber {
                            Text("\(num)")
                                .font(.largeTitle)
                                .frame(width: 50, height: 50, alignment: .center)
                                .foregroundColor(.white)
                                .background(.black)
                                .border(.white)
                                .offset(
                                    x: proxy.frame(in: .local).minX,
                                    y: proxy.frame(in: .local).minY
                                )
                        }
                    }
                }
            
            Text("書き取りモード")
                .frame(width: 150, height: 30)
                .roundedRectangleBorder(
                    .blue,
                    width: 1,
                    radius: 10,
                    background: .blue
                )
                .foregroundStyle(.white)
                .padding(.top)
        }
    }
    
    private var canvasAnswerButton: some View {
        Button(action: {
            store.send(.view(.didDrawingCanvas(canvasView.canvas)))
            canvasView.reset()
        }) {
            Text("Go")
                .font(.title2)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, maxHeight: 50)
        }
        .background(.blue)
        .cornerRadius(10)
    }
}


