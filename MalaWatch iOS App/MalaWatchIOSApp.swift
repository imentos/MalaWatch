import SwiftUI

@main
struct MalaWatchIOSApp: App {
    @State private var store = MalaStore()

    var body: some Scene {
        WindowGroup {
            iOSCounterView()
                .environment(store)
        }
    }
}
