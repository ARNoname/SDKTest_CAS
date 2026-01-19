
import SwiftUI
import WebKit

public struct WebViewWrapper: UIViewRepresentable {
    public let url: URL
    public let onLoad: () -> Void

    public init(url: URL, onLoad: @escaping () -> Void) {
        self.url = url
        self.onLoad = onLoad
    }

    public func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }

    public func updateUIView(_ uiView: WKWebView, context: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    public class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebViewWrapper

        init(parent: WebViewWrapper) {
            self.parent = parent
        }

        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
             parent.onLoad()
        }
        
        // Force navigation in the same view (optional, based on your previous code)
        public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
            return .allow
        }
    }
}
