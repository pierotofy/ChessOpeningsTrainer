//
//  HtmlStringView.swift
//  chessopeningstrainer (iOS)
//
//  Created by Piero on 12/25/21.
//

import WebKit
import SwiftUI

struct HtmlStringView: UIViewRepresentable {

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        private let parent: HtmlStringView

        init(_ parent: HtmlStringView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            self.parent.onLoad()
       }
    }
    
    let htmlContent: String
    let onLoad: () -> Void

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.navigationDelegate = context.coordinator
        uiView.loadHTMLString(htmlContent, baseURL: nil)
    }
}
