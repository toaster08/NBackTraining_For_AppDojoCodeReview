//
//  GameModeType.swift
//  NBackTraining
//
//  Created by 山田　天星 on 2024/03/30.
//

import Foundation

enum GameModeType: String, CaseIterable, Identifiable {
    case tapping
    case writing
    
    var id: Self { self }
    var name: String {
        switch self {
        case .tapping: "ボタン"
        case .writing: "書き取り"
        }
    }
}
