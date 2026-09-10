import SwiftUI
import WebKit

/// Aroro is rendered from the same offline game bundle as the browser preview.
/// This keeps iPhone and web on one set of levels, controls, visuals, and rules.
struct ContentView: View {
    var body: some View {
        AroroGameWebView()
            .ignoresSafeArea()
            .accessibilityLabel("Aroro oyun alanı")
    }
}

private struct AroroGameWebView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = false

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.isOpaque = false
        webView.backgroundColor = UIColor(red: 0.961, green: 0.941, blue: 0.902, alpha: 1)
        webView.scrollView.backgroundColor = webView.backgroundColor
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.allowsLinkPreview = false
        webView.accessibilityLabel = "Aroro oyun alanı"

        guard let indexURL = Bundle.main.url(
            forResource: "index",
            withExtension: "html",
            subdirectory: "web-preview"
        ) else {
            assertionFailure("Bundled Aroro game files could not be found.")
            return webView
        }

        webView.loadFileURL(indexURL, allowingReadAccessTo: indexURL.deletingLastPathComponent())
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

#Preview {
    ContentView()
}
