//
//  GameState.swift
//  NBackTraining
//
//  Created by 山田　天星 on 2024/04/06.
//

import Foundation

enum GameState: Equatable {
    case notPlay
    case start
    case playing(state: PlayingState)
    case gameEnd(nBackCount: Int)

    enum PlayingState {
        case memorizeOnly
        case memorizeAndAnswer
        case answerOnly
    }
    
    var isAnswerable: Bool {
        self == .playing(state: .memorizeAndAnswer) || self == .playing(state: .answerOnly)
    }
}
