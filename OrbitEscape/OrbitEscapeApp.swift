import SwiftUI

@main
struct OrbitEscapeApp: App {
    @State private var progress = PlayerProgress()

    var body: some Scene {
        WindowGroup {
            ContentView(progress: progress)
                .preferredColorScheme(.dark)
        }
    }
}
