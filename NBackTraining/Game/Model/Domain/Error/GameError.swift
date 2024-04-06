//
//  GameError.swift
//  NBackTraining
//
//  Created by 山田　天星 on 2024/03/23.
//

import Foundation

enum GameError: Error, Equatable {
    case unknown
}

enum NBackTrainingDomainError: Error {
    case decodingError
}
