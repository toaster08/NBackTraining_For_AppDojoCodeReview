//
//  UseCase.swift
//  NBackTraining
//
//  Created by 山田　天星 on 2022/06/05.
//

import Foundation

import Dependencies

enum Answer {
    case correct
    case incorrect
}

enum Evaluation: Equatable {
    case up(result: Int)
    case noChange(result: Int)
    case down(result: Int)
    
    static func get(from value: Int) -> Self {
        if value >= 80 {
            return .up(result: value)
        } else if value >= 60 {
            return .noChange(result: value)
        } else {
            return .down(result: value)
        }
    }
}

enum Grade {
    case high
    case middle
    case low
}

final class GameUseCase {
    static let lowerNBackCountLevel: Int = 3
    
    @Dependency(\.userSettingRepository) var repository
    
    private var defaultTrainingCount: Int {
        #if DEBUG
                2 + repository.loadNBackLevel()
        #else
                20 + repository.loadNBackLevel()
        #endif
    }
    
    func answeredWithInTime(_ input: Int?, for currentAnswerProblem: Problem) -> Answer {
        guard let input else { return .incorrect }
        let answer = judge(input, for: currentAnswerProblem)
        return answer
    }
    
    func notAnsweredWithInTime() -> Answer {
        return .incorrect
    }
    
    func generateProblemList() -> [Problem] {
        let problems = (1...defaultTrainingCount).map { _ in Problem() }
        return problems
    }
    
    func getResultGrading(_ correctAnswerPercent: Int) -> Evaluation {
        let grading = Evaluation.get(from: correctAnswerPercent)
        return grading
    }
    
    func judge(_ input: Int, for currentAnswerProblem: Problem) -> Answer {
        let totalNumber = currentAnswerProblem.totalNumber
        return totalNumber == input ? .correct : .incorrect
      
    }

    func updateNBackCountLevel(_ grading: Evaluation, currentLevel: Int) -> Int {
        switch grading {
        case .up:
            let newLevel = currentLevel + 1
            repository.saveNBackLevel(newLevel)
            return newLevel
        case .down:
            if currentLevel > Self.lowerNBackCountLevel {
                let newLevel = currentLevel - 1
                repository.saveNBackLevel(newLevel)
                return newLevel
            } else {
                return currentLevel
            }
        case .noChange:
            return currentLevel
        }
    }
    
    func getAnswerPercentage(from answerList: [Answer]) throws -> Int {
        // FIXME: game error
        guard answerList.count != .zero else {  throw GameError.unknown }
        let answerResultCount = answerList.count
        let correctCount = answerList.filter { $0 == .correct }.count
        let accuracyPercent = (correctCount / answerResultCount) * 100
        return  Int(accuracyPercent)
    }
}
