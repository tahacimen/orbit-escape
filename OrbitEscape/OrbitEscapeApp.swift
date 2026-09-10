import SwiftUI

@main
struct AroroApp: App {
    @State private var progress = PlayerProgress()

    var body: some Scene {
        WindowGroup {
            ContentView(progress: progress)
                .preferredColorScheme(.dark)
        }
    }
}
