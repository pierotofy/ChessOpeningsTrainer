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
    @StateObject var storeManager = StoreManager()
    @ObservedObject var webViewModel: WebViewModel
    @State var descrPgn: String = ""
    @State var showSettings: Bool = false
    @State var sMaxTreeMoves: Float = Float(AppSettings.shared.maxTreeMoves)
    @State var exploreOpening: Opening?
    @State var trainOpening: Opening?
    var treeTrainMode: Bool = false
    @State var ttStartingPosition: String = AppSettings.shared.ttStartingPosition
    
    let webView: WebViewContainer
    
    private var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    
    
    init(color: String, maxTreeMoves: Int, mode: String){
        var wvm: WebViewModel
        
        if mode == "treetrain"{
            wvm = WebViewModel(color: color, maxTreeMoves: maxTreeMoves, mode: mode, uci: AppSettings.shared.ttStartingPosition)
        }else{
            wvm = WebViewModel(color: color, maxTreeMoves: maxTreeMoves, mode: mode)
        }
        self.webViewModel = wvm
        self.webView = WebViewContainer(webViewModel: wvm)
        
        treeTrainMode = mode == "treetrain"
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
                    trainOpening = webViewModel.playedOpening
                }){
                    Image(systemName: "play.circle")
                }.disabled(webViewModel.playedOpening == nil)
                
                Button(action: {
                    descrPgn = webViewModel.playedOpening!.pgn
                }){
                    Image(systemName: "info.circle")
                }.disabled(webViewModel.playedOpening == nil || webViewModel.playedOpening!.descr == nil)
                        
                Button(action: webView.toggleColor){
                    Image(systemName: "circle.righthalf.filled")
                }
                Button(action: {
                    showSettings = true
                }){
                    Image(systemName: "gearshape")
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
                        if treeTrainMode {
                            Button(action: webView.setTreeTrainMode){
                                HStack{
                                    Image(systemName: "arrow.counterclockwise")
                                    Text("Restart")
                                }.frame(maxWidth: .infinity, minHeight: 36)
                            }.buttonStyle(.borderedProminent)
                                .tint(Color.background)
                                .foregroundColor(.primary)
                        }else{
                            Button(action: webView.rewind){
                                HStack{
                                    Image(systemName: "arrow.counterclockwise")
                                    Text("Rewind")
                                }.frame(maxWidth: .infinity, minHeight: 36)
                            }.buttonStyle(.borderedProminent)
                                .tint(Color.background)
                                .foregroundColor(webViewModel.canPlayBack ? .primary : .gray)
                        }
                        
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
                        
                        if treeTrainMode {
                            Button(action: {
                                webView.showHint()
                            }){
                                HStack{
                                    Image(systemName: "questionmark.circle")
                                    Text("Hint")
                                }.frame(maxWidth: .infinity, minHeight: 36)
                            }.buttonStyle(.borderedProminent)
                                .tint(Color.background)
                            .foregroundColor(.primary)
                        }
                        
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
                .sheet(isPresented: $showSettings, onDismiss: {
                    if AppSettings.shared.maxTreeMoves != Int(sMaxTreeMoves){
                        AppSettings.shared.maxTreeMoves = Int(sMaxTreeMoves)
                        webView.setMaxTreeMoves(maxTreeMoves: Int(sMaxTreeMoves))
                    }
                    
                    if treeTrainMode && AppSettings.shared.ttStartingPosition != ttStartingPosition{
                        AppSettings.shared.ttStartingPosition = ttStartingPosition
                        webView.setUCI(uci: ttStartingPosition)
                    }
                }){
                    VStack{
                        HStack{
                            Text("Settings").font(.largeTitle).frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            Spacer()
                            Button(action: {
                                showSettings = false
                            }, label: {
                                Image(systemName: "xmark.circle.fill")
                            })
                            .padding()
                        }
                        
                        if treeTrainMode {
                            HStack{
                                Text("Starting Position: ").fontWeight(.bold)
                                Picker("Random", selection: $ttStartingPosition) {
                                    ForEach(OpeningMovesModel.shared.getForMaxMovesWithRandom(Int(sMaxTreeMoves)), id: \.self.uci) {
                                        Text($0.name)
                                    }
                                }
                                .pickerStyle(.wheel)
                            }
                        }
                        
                        HStack{
                            Text("Max Openings: ").fontWeight(.bold)
                            Text(String(Int(sMaxTreeMoves))).padding(.trailing, 16)
                            Slider(value: $sMaxTreeMoves,
                                   in: 1...(storeManager.isPro ? 20 : 4),
                                   step: 1)
                        }
                        
                        Spacer()
                        if !storeManager.isPro{
                            VStack{
                                Text("Upgrade to Pro to explore and practice up to 20 openings on the board! It's a one-time purchase and helps support the development of the app ♥")
                                Button(action: {
                                    storeManager.purchase()
                                }, label: {
                                    if storeManager.purchasing{
                                        Image(systemName: "hour")
                                    }else{
                                        Image(systemName: "bolt.fill")
                                    }
                                    Text("Upgrade to Pro")
                                })
                                    .disabled(storeManager.purchasing)
                                .padding()
                                Button(action: {
                                    storeManager.restore()
                                }, label: {
                                    Image(systemName: "arrow.uturn.forward")
                                    Text("Restore Purchase")
                                })
                            }
                        }else{
                            Text("You are using the Pro version. Thanks for the support! ♥")
                        }
                        
                    }.padding(16)
                        .frame(minHeight: 0, maxHeight: .infinity, alignment: .top)
                }
        
        }.navigationViewStyle(.stack)
    }
}

struct BoardTreeView_Previews: PreviewProvider{
    static var previews: some View{
        BoardTreeView(color: "white", maxTreeMoves: 5, mode: "tree")
    }
}
