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
    
    private var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    
    
    init(_ opening: Opening, color: String, mode: String){
        self.opening = opening
        
        let wvm =  WebViewModel(uci: opening.uci, color: color, mode: mode)
        
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
                    HStack{
                        Image(systemName: webViewModel.mode == "explore" ? "play.circle" : "stop.circle")
                        if idiom != .phone{
                            Text(webViewModel.mode == "explore" ? "Start Training" : "Stop Training")
                        }
                    }.frame(maxWidth: .infinity, minHeight: 36)
                }.buttonStyle(.borderedProminent)
                .tint(Color.background)
                .foregroundColor(Color.primary)
                
                Button(action: webView.rewind){
                    HStack{
                        Image(systemName: "arrow.counterclockwise")
                        if idiom != .phone{
                            Text("Rewind")
                                
                        }
                    }.frame(maxWidth: .infinity, minHeight: 36)
                }.buttonStyle(.borderedProminent)
                .disabled(webViewModel.mode != "explore")
                .tint(.background)
                .foregroundColor(webViewModel.canPlayBack ? .primary : .gray)
                
                Button(action: {
                    webView.playBack()
                }){
                    HStack{
                        Image(systemName: "chevron.left")
                        if idiom != .phone{
                            Text("Back")
                        }
                    }.frame(maxWidth: .infinity, minHeight: 36)
                }.buttonStyle(.borderedProminent)
                .disabled(webViewModel.mode != "explore")
                .tint(.background)
                .foregroundColor(webViewModel.canPlayBack ? .primary : .gray)
                
                Button(action: {
                    webView.playForward()
                }){
                    HStack{
                        if idiom != .phone{
                            Text("Forward")
                        }
                        Image(systemName: "chevron.right")
                    }.frame(maxWidth: .infinity, minHeight: 36)
                    
                }.buttonStyle(.borderedProminent)
                .disabled(webViewModel.mode != "explore")
                .tint(.background)
                .foregroundColor(webViewModel.canPlayFoward ? .primary : .gray)
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
        BoardView(Opening(name: "test", uci: "e2e4", pgn: "", rank: 50), color: "white", mode: "explore")
    }
}
