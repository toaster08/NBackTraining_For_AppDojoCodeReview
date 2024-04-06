import Foundation

import Dependencies

protocol SettingRepository: Sendable  {
    func saveNBackLevel(_ nBackLevel: Int) -> Void
    func loadNBackLevel() -> Int
}

private extension UserSettingRepository {
    static let nBackLevelKey: String = "nBack"
    static let userSettingKey: String = "SettingData"
}
 
public final class UserSettingRepository: Sendable, SettingRepository {
    
    private let userdefaluts = UserDefaults.standard
    
    func saveNBackLevel(_ nBackLevel: Int) {
        userdefaluts.set(nBackLevel, forKey: Self.nBackLevelKey)
    }
    
    func loadNBackLevel() -> Int {
        let nbackLevel = userdefaluts.integer(forKey: Self.nBackLevelKey)
        return nbackLevel >= 3 ? nbackLevel : 3
    }
}

private enum UserSettingRepositoryKey: DependencyKey {
    static let liveValue = UserSettingRepository()
}

extension DependencyValues {
    public var userSettingRepository: UserSettingRepository {
        get { self[UserSettingRepositoryKey.self] }
        set { self[UserSettingRepositoryKey.self] = newValue }
    }
}
