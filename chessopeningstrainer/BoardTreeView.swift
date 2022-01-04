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
    
    private var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    
    
    init(color: String){
        let wvm = WebViewModel(color: color)
        self.webViewModel = wvm
        self.webView = WebViewContainer(webViewModel: wvm)
    }
    
    var board: some View{
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
    }
    
    var openingsModal : some View{
        if webViewModel.showOpenings != nil {
            return AnyView(ShowOpeningsView(openings: webViewModel.showOpenings!, onExploreOpening: { o in
                exploreOpening = o
            },
             onTrainOpening: { o in
                trainOpening = o
            },
             onClose: {
                withAnimation{
                    webViewModel.showOpenings = nil
                }
            }))
        }else{
            return AnyView(EmptyView().hidden())
        }
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
                
                if idiom == .phone{
                    ZStack{
                        board
                        openingsModal.padding(16)
                    }
                }else{
                    HStack{
                        board
                        openingsModal.padding(EdgeInsets(top: 16, leading: 2, bottom: 16, trailing: 16))
                    }
                }
                
                VStack{
                    HStack {
                        Button(action: webView.rewind){
                            HStack{
                                Image(systemName: "arrow.counterclockwise")
                                Text("Rewind")
                            }.frame(maxWidth: .infinity, minHeight: 36)
                        }.buttonStyle(.borderedProminent)
                        .tint(Color.background)
                        .foregroundColor(webViewModel.canPlayBack ? .primary : .gray)
                        
                        Button(action: {
                            webView.playBack()
                        }){
                            HStack{
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }.frame(maxWidth: .infinity, minHeight: 36)
                        }.buttonStyle(.borderedProminent)
                            .tint(Color.background)
                        .foregroundColor(webViewModel.canPlayBack ? .primary : .gray)
                        
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
