import SwiftUI

@main
struct AroroApp: App {
    @State private var progress = PlayerProgress()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
    }
}
