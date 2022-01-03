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
    @State var descrPgn: String = ""
    @State var exploreOpening: Opening?
    @State var trainOpening: Opening?
    
    let webView: WebViewContainer
    
    init(color: String){
        let wvm = WebViewModel(color: color)
        self.webViewModel = wvm
        self.webView = WebViewContainer(webViewModel: wvm)
    }
    
    var body: some View{
        let showDescription = Binding(get: { descrPgn != "" }, set: { descrPgn = $0 ? descrPgn : "" })
        let doExploreOpening = Binding(get: { exploreOpening != nil }, set: { exploreOpening = $0 ? exploreOpening : nil})
        let doTrainOpening = Binding(get: { trainOpening != nil }, set: { trainOpening = $0 ? trainOpening : nil})
        
        
        NavigationView{
            if exploreOpening != nil{
                NavigationLink(destination: BoardView(exploreOpening!, color: AppSettings.shared.color, mode: "explore"), isActive: doExploreOpening){ EmptyView() }.hidden()
            }
            if trainOpening != nil{
                NavigationLink(destination: BoardView(trainOpening!, color: AppSettings.shared.color, mode: "training"), isActive: doTrainOpening){ EmptyView() }.hidden()
            }
            
            VStack{
                ZStack {
                    webView
                        .onTapGesture {
                            webViewModel.showOpenings = nil
                        }
                    if webViewModel.isLoading {
                        ProgressView()
                            .frame(height: 30)
                    }
                    
                    if webViewModel.showOpenings != nil {
                            ShowOpeningsView(openings: webViewModel.showOpenings!, onExploreOpening: { o in
                                exploreOpening = o
                            },
                             onTrainOpening: { o in
                                trainOpening = o
                            },
                             onClose: {
                                webViewModel.showOpenings = nil
                            }).padding(EdgeInsets(top: 64, leading: 16, bottom: 64, trailing: 16))

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
        
        }.navigationViewStyle(.stack)
    }
}

struct BoardTreeView_Previews: PreviewProvider{
    static var previews: some View{
        BoardTreeView(color: "white")
    }
}
