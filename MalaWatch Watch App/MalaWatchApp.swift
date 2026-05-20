import SwiftUI

@main
struct MalaWatchApp: App {
    @State private var store = MalaStore()

    var body: some Scene {
        WindowGroup {
            WatchCounterView()
                .environment(store)
        }
    }
}
