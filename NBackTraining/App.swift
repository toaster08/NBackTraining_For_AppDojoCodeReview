import SwiftUI

import Dependencies

class CustomAppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
}

@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor(CustomAppDelegate.self) var appDelegate
    @Dependency(\.userSettingRepository) var repository

    var body: some Scene {
        WindowGroup {
            let initialReducer = Game.State(
                timeProgressReducer: .init(),
                startPreparationReducer: .init(), 
                resultReducer: .init(),
                nBackCountLevel: 3
            )
            GameView(store: .init(initialState: initialReducer, reducer: {
                Game(useCase: .init())
            }))
        }
    }
}
