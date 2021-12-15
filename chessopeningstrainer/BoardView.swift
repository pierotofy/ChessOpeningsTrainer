//
//  GameSelectionView.swift
//  chessopeningstrainer (iOS)
//
//  Created by Piero on 12/8/21.
//

import Foundation
import SwiftUI

struct BoardView: View{
    @ObservedObject var webViewModel = WebViewModel()
    var selectedOpening: Opening
    
    var body: some View{
        VStack{
            ZStack {
                WebViewContainer(webViewModel: webViewModel)
                if webViewModel.isLoading {
                    ProgressView()
                        .frame(height: 30)
                }
            }
            .navigationBarTitle(Text(selectedOpening.name), displayMode: .inline)
            .frame(maxHeight: .infinity, alignment: .leading)
            
            ControlGroup {
                Button(action: {
                    print("YO")
                }){
                    Image(systemName: "arrowtriangle.left.circle.fill")
                    Text("Back")
                        .frame(minWidth: 0, maxWidth: .infinity)
                    
                }.buttonStyle(.bordered)
                    .disabled(!webViewModel.canPlayBack)
                
                Button(action: {
                    print("YO")
                }){
                    Text("Forward")
                        .frame(minWidth: 0, maxWidth: .infinity)
                    Image(systemName: "arrowtriangle.right.circle.fill")
                    
                }.buttonStyle(.bordered)
                    .disabled(!webViewModel.canPlayFoward)
            }.controlGroupStyle(.navigation).padding()
        }
    }
}

struct BoardView_Previews: PreviewProvider{
    static var previews: some View{
        BoardView(selectedOpening: Opening(name: "test", uci: "", pgn: ""))
    }
}
