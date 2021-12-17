//
//  GameSelectionView.swift
//  chessopeningstrainer (iOS)
//
//  Created by Piero on 12/8/21.
//

import Foundation
import SwiftUI

struct BoardView: View{
    @ObservedObject var webViewModel: WebViewModel
    var opening: Opening
    let webView: WebViewContainer
    
    init(_ opening: Opening){
        self.opening = opening
        
        let wvm = WebViewModel()
        self.webViewModel = wvm
        self.webView = WebViewContainer(webViewModel: wvm)
    }
    
    var body: some View{
        VStack{
            ZStack {
                webView
                if webViewModel.isLoading {
                    ProgressView()
                        .frame(height: 30)
                }
            }
            .navigationBarTitle(Text(opening.name), displayMode: .inline)
            .frame(maxHeight: .infinity, alignment: .leading)
            
            ControlGroup {
                Button(action: {
                    webView.playBack()
                }){
                    Image(systemName: "chevron.left")
                    Text("Back")
                        .frame(minWidth: 0, maxWidth: .infinity)
                    
                }.buttonStyle(.bordered)
                .disabled(!webViewModel.canPlayBack)
                .background(.white)
                
                Button(action: {
                    webView.playForward()
                }){
                    Text("Forward")
                        .frame(minWidth: 0, maxWidth: .infinity)
                    Image(systemName: "chevron.right")
                    
                }.buttonStyle(.bordered)
                .disabled(!webViewModel.canPlayFoward)
                .background(.white)
            }.controlGroupStyle(.navigation).padding()
                
            
                
        }.background(Image("BoardBackground").resizable(resizingMode: .tile))
    }
}

struct BoardView_Previews: PreviewProvider{
    static var previews: some View{
        BoardView(Opening(name: "test", uci: "", pgn: ""))
    }
}
