//
//  WebViewContainer.swift
//  chessopeningstrainer
//
//  Created by Piero on 12/8/21.
//

import SwiftUI
import UIKit
import WebKit

struct WebViewContainer: UIViewRepresentable {
    class Coordinator: NSObject, WKNavigationDelegate {
        @ObservedObject private var webViewModel: WebViewModel
        private let parent: WebViewContainer
        
        init(_ parent: WebViewContainer, _ webViewModel: WebViewModel) {
            self.parent = parent
            self.webViewModel = webViewModel
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            webViewModel.isLoading = true
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webViewModel.isLoading = false
            webViewModel.title = webView.title ?? ""
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            webViewModel.isLoading = false
        }
    }
    
    class JSHandler: NSObject, WKScriptMessageHandler{
        @ObservedObject private var webViewModel: WebViewModel
        
        init(_ webViewModel: WebViewModel){
            self.webViewModel = webViewModel
        }
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if let messageBody = message.body as? String {
                print("Received: \(messageBody)")
                let components = messageBody.components(separatedBy: "=")
                if components.count == 2 {
                    let key = components[0];
                    let value = components[1];
                    print("Got: \(key) --> \(value)")
                    
                    switch key {
                    case "canPlayForward":
                        self.webViewModel.canPlayFoward = value == "true"
                    case "canPlayBack":
                        self.webViewModel.canPlayBack = value == "true"
                    default:
                        print("Unknown key \(key)")
                    }
                }else{
                    print("Invalid message: \(messageBody)")
                }
            }
        }
    }
    
    @ObservedObject var webViewModel: WebViewModel
    private let webView = WKWebView()
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Pass
    }
    
    func makeCoordinator() -> WebViewContainer.Coordinator {
        Coordinator(self, webViewModel)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let request = URLRequest(url: webViewModel.url)
        webView.navigationDelegate = context.coordinator
        webView.configuration.userContentController.add(JSHandler(webViewModel), name: "jsHandler")
        webView.load(request)
        
        return webView
    }
    
    func dispatchEvent(_ eventName: String){
        webView.evaluateJavaScript("_handleMessage('dispatchEvent', '\(eventName)')")
    }
    
    func playForward(){
        dispatchEvent("playForward")
    }
    
    func playBack(){
        dispatchEvent("playBack")
    }
}
