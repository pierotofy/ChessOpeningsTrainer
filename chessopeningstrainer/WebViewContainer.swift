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
                        webViewModel.canPlayFoward = value == "true"
                    case "canPlayBack":
                        webViewModel.canPlayBack = value == "true"
                    case "toggledColor":
                        AppSettings.shared.color = value
                    case "setMode":
                        webViewModel.mode = value
                    case "playedOpening":
                        webViewModel.playedOpening = Opening.loadFromJSON(value)
                    case "showOpenings":
                        withAnimation{
                            webViewModel.showOpenings = Opening.loadFromJSONArray(value)
                        }
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
        if (webView.backgroundColor != .clear){
            let request = URLRequest(url: webViewModel.getURL())
            
            webView.navigationDelegate = context.coordinator
            webView.configuration.userContentController.add(JSHandler(webViewModel), name: "jsHandler")

            webView.load(request)
            
            webView.isOpaque = false
            webView.backgroundColor = .clear
            webView.scrollView.backgroundColor = .clear
        }
        
        return webView
    }
    
    func sendMessage(_ key: String, value: String){
        webView.evaluateJavaScript("_handleMessage('\(key)', '\(value)')")
    }
    
    func dispatchEvent(_ eventName: String){
        sendMessage("dispatchEvent", value: eventName)
    }
    
    func playForward(){
        dispatchEvent("playForward")
    }
    
    func playBack(){
        dispatchEvent("playBack")
    }
    
    func rewind(){
        dispatchEvent("rewind")
    }
    
    func toggleColor(){
        dispatchEvent("toggleColor")
    }
    
    func setTrainingMode(){
        dispatchEvent("setTrainingMode")
    }
    
    func setExploreMode(){
        dispatchEvent("setExploreMode")
    }
    
    func setTreeTrainMode(){
        dispatchEvent("setTreeTrainMode")
    }
    
    func setMaxTreeMoves(maxTreeMoves: Int){
        sendMessage("setMaxTreeMoves", value: String(maxTreeMoves))
    }
    
    func setUCI(uci: String){
        sendMessage("setUCI", value: uci)
    }
    
    func showHint(){
        dispatchEvent("showHint")
    }
}
