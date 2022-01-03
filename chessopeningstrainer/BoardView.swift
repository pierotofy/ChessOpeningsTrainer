//
//  GameSelectionView.swift
//  chessopeningstrainer (iOS)
//
//  Created by Piero on 12/8/21.
//

import Foundation
import SwiftUI
import WebKit

struct BoardView: View{
    @ObservedObject var webViewModel: WebViewModel
    @State public var descrPgn: String = ""
    
    var opening: Opening
    let webView: WebViewContainer
    
    init(_ opening: Opening, color: String){
        self.opening = opening
        
        let wvm =  WebViewModel(uci: opening.uci, color: color)
        
        self.webViewModel = wvm
        self.webView = WebViewContainer(webViewModel: wvm)
    }
    
    var body: some View{
        let showDescription = Binding(get: { descrPgn != "" }, set: { descrPgn = $0 ? descrPgn : "" })
        
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
            .toolbar{
                HStack{
                    if (opening.descr != nil){
                        Button(action: {
                            descrPgn = opening.pgn
                        }){
                            Image(systemName: "info.circle")
                        }
                    }
                    Button(action: webView.toggleColor){
                        Image(systemName: "circle.righthalf.filled")
                    }
                }
            }
            
            HStack{
                Button(action: {
                    if (webViewModel.mode == "explore"){
                        webView.setTrainingMode();
                    }else{
                        webView.setExploreMode();
                    }
                }){
                    Image(systemName: webViewModel.mode == "explore" ? "play.circle" : "stop.circle")
                    Text(webViewModel.mode == "explore" ? "Start Training" : "Stop Training")
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 36)
                }.buttonStyle(.borderedProminent)
                .tint(.white)
                .foregroundColor(.black)
                
                Button(action: webView.rewind){
                    Image(systemName: "arrow.counterclockwise")
                    Text("Rewind")
                        .frame(minWidth: 0, maxWidth: .infinity,  minHeight: 36)
                    
                }.buttonStyle(.borderedProminent)
                .disabled(webViewModel.mode != "explore")
                .tint(.white)
                .foregroundColor(webViewModel.canPlayBack ? .black : .gray)
                
                Button(action: {
                    webView.playBack()
                }){
                    Image(systemName: "chevron.left")
                    Text("Back")
                        .frame(minWidth: 0, maxWidth: .infinity,  minHeight: 36)
                    
                }.buttonStyle(.borderedProminent)
                .disabled(webViewModel.mode != "explore")
                .tint(.white)
                .foregroundColor(webViewModel.canPlayBack ? .black : .gray)
                
                Button(action: {
                    webView.playForward()
                }){
                    Text("Forward")
                        .frame(minWidth: 0, maxWidth: .infinity,  minHeight: 36)
                    Image(systemName: "chevron.right")
                    
                }.buttonStyle(.borderedProminent)
                .disabled(webViewModel.mode != "explore")
                .tint(.white)
                .foregroundColor(webViewModel.canPlayFoward ? .black : .gray)
            }.padding(EdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16))

            
            }.background(Image("BoardBackground").resizable(resizingMode: .tile))
            .sheet(isPresented: showDescription, onDismiss: {
            }){
                VStack{
                    HStack{
                        Spacer()
                        Button(action: {
                            descrPgn = ""
                        }, label: {
                            Image(systemName: "xmark.circle.fill")
                        })
                        .padding()
                    }
                    DescriptionView(pgn: descrPgn)
                }
            }
    }
}

struct BoardView_Previews: PreviewProvider{
    static var previews: some View{
        BoardView(Opening(name: "test", uci: "e2e4", pgn: "", rank: 50), color: "white")
    }
}
