//
//  GameSelectionView.swift
//  chessopeningstrainer (iOS)
//
//  Created by Piero on 12/8/21.
//

import Foundation
import SwiftUI
import WebKit

struct BoardTreeView: View{
    @ObservedObject var webViewModel: WebViewModel
    @State public var descrPgn: String = ""
    let webView: WebViewContainer
    
    init(color: String){
        
        let wvm = WebViewModel(color: color)
        self.webViewModel = wvm
        self.webView = WebViewContainer(webViewModel: wvm)
    }
    
    var body: some View{
        let showDescription = Binding(get: { descrPgn != "" }, set: { descrPgn = $0 ? descrPgn : "" })
        let showOpenings = Binding(get: { webViewModel.showOpenings != nil }, set: { webViewModel.showOpenings = $0 ? webViewModel.showOpenings : nil })
        
        NavigationView{
            VStack{
                ZStack {
                    webView
                    if webViewModel.isLoading {
                        ProgressView()
                            .frame(height: 30)
                    }
                }
                .navigationBarTitle(Text(webViewModel.playedOpening != nil ? webViewModel.playedOpening!.name : "Waiting for a move..."), displayMode: .inline)
                .frame(maxHeight: .infinity, alignment: .leading)
                .toolbar{
                    HStack{

                        Button(action: {
                            descrPgn = webViewModel.playedOpening!.pgn
                        }){
                            Image(systemName: "info.circle")
                        }.disabled(webViewModel.playedOpening == nil || webViewModel.playedOpening!.descr == nil)
                                
                        Button(action: webView.toggleColor){
                            Image(systemName: "circle.righthalf.filled")
                        }
                    }
                }
                
                VStack{
                    HStack {
                        Button(action: webView.rewind){
                            Image(systemName: "arrow.counterclockwise")
                            Text("Rewind")
                                .frame(minWidth: 0, maxWidth: .infinity,  minHeight: 36)
                            
                        }.buttonStyle(.borderedProminent)
                        .tint(.white)
                        .foregroundColor(webViewModel.canPlayBack ? .black : .gray)
                        
                        Button(action: {
                            webView.playBack()
                        }){
                            Image(systemName: "chevron.left")
                            Text("Back")
                                .frame(minWidth: 0, maxWidth: .infinity,  minHeight: 36)
                            
                        }.buttonStyle(.borderedProminent)
                        .tint(.white)
                        .foregroundColor(webViewModel.canPlayBack ? .black : .gray)
                        
                    }.padding(EdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16))
                }
                
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
            
                .sheet(isPresented: showOpenings){
                    VStack{
                        HStack(alignment: .top){
                            Spacer()
                            Button(action: {
                                webViewModel.showOpenings = nil
                            }, label: {
                                Image(systemName: "xmark.circle.fill")
                            })
                            .padding()
                        }
                        ShowOpeningsView(openings: webViewModel.showOpenings!)
                            
                    }.frame(maxHeight: .infinity, alignment: .top)
                }
        
        }.navigationViewStyle(.stack)
    }
}

struct BoardTreeView_Previews: PreviewProvider{
    static var previews: some View{
        BoardTreeView(color: "white")
    }
}
