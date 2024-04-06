import SwiftUI
import Combine

struct GameRuleView: View {
    @SwiftUI.State private var animationAmount: CGFloat = 1
    @SwiftUI.State private var selectedStep = 1
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 30) {
                    Image(systemName: "gamecontroller.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 70, height: 70)
                    Text("Rules📚")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .padding(.leading, 30)
                
                Divider()

                Text("急がず、だが休むことなく - ゲーテ")
                    .font(.headline)
                    .padding(.horizontal, 10)
                
                Divider()
                VStack(alignment: .leading) {
                    Text("📖 ルール")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading) {
                        HStack {
                            HStack {
                                Image(systemName: "play.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .padding()
                            }
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(10)
                            Text("このトレーニングは、N個前に出された問題に対して答えるNバック訓練というものです. 現在のNがいくつかはゲームはHOME画面上で表示されます。")
                                .font(.headline)
                        }
                        
                        Divider().padding()
                        
                        HStack {
                            HStack {
                                Image(systemName: "arrow.3.trianglepath")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .padding()
                                    .scaleEffect(animationAmount)
                                    .onAppear {
                                        withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                                            animationAmount = 0.9
                                        }
                                    }
                            }
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(10)
                            Text("🧠Memorize the answers to the N formulas displayed at the beginning. The time displayed is 3 seconds.⏳")
                                .font(.headline)
                        }
                        
                        
                        Divider().padding()
                        
                        HStack {
                            HStack {
                                Image(systemName: "clock.arrow.circlepath")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .padding()
                            }
                            .background(Color.red.opacity(0.2))
                            .cornerRadius(10)
                            Text("From the next question, ✏️answer the results of the N previous questions at the same time as you remember them. Repeat this for 20 questions to finish.")
                                .font(.headline)
                        }
                    }
                    .padding()
                }
                
                Divider()
                
                VStack(alignment: .leading) {
                    Text("Example：3 back🏃")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.bottom, 10)
                    
                    HStack(spacing: 30) {
                        Image(systemName: "questionmark.diamond.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                        VStack {
                            ForEach(1...5, id: \.self) { stepNumber in
                                StepView(stepNumber: stepNumber, selectedStep: $selectedStep)
                            }
                        }
                    }
                }
                .padding()
                
                Divider()
                
                VStack(alignment: .leading) {
                    Text("Level Up")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 30) {
                        Image(systemName: "arrow.up.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                        QuizProgressView()
                    }
                }
                .padding()

            }
            .padding()
        }
    }
}

struct QuizProgressView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Level up/down depends on answer accuracy")
            Divider()
            VStack(alignment: .leading, spacing: 10) {
                Text("Green: 80% or more correct answers, you will Level Up ➡️ N+1")
                    .foregroundColor(.green)
                Text("Yellow: 60% to 79% correct answers, your Level will remain the same ➡️ N")
                    .foregroundColor(.yellow)
                Text("Red: Less than 60% correct answers, you will Level Down ➡️ N-1")
                    .foregroundColor(.red)
            }

            Divider()
        }
        .padding()
    }
}




struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        GameRuleView()
    }
}

struct StepView: View {
    let stepNumber: Int
    @Binding var selectedStep: Int
    
    var body: some View {
        Group {
            if stepNumber <= selectedStep {
                HStack {
                    Text(question())
                        .font(.title2)
                        .foregroundColor(stepNumber == selectedStep ? Color.blue : Color.gray)
                    
                    Spacer()
                    
                    if stepNumber == 4 || stepNumber == 5 {
                        Text(answer())
                            .font(.headline)
                            .foregroundColor(Color.red)
                    } else {
                        Text("remenber")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Color.red)
                    }
                    
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                .onTapGesture {
                    if selectedStep < 7 {
                        withAnimation {
                            selectedStep += 1
                        }
                    }
                }
                if selectedStep <= stepNumber {
                      Text("...")
                          .font(.largeTitle)
                          .padding(.top, 10)
                }
            }
        }
    }
    
    func question() -> String {
        switch stepNumber {
        case 1:
            return "Q1:   1 + 6"
        case 2:
            return "Q2:   3 + 2"
        case 3:
            return "Q3:   5 - 1"
        case 4:
            return "Q4:   5 + 1"
        case 5:
            return "Q5:   7 + 2"
        default:
            return ""
        }
    }
    
    func answer() -> String {
        switch stepNumber {
        case 4:
            return "7 (1 + 6)"
        case 5:
            return "5 (3 + 2)"
        default:
            return ""
        }
    }
}
