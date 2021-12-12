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
            ZStack {
                WebViewContainer(webViewModel: webViewModel)
                if webViewModel.isLoading {
                    ProgressView()
                        .frame(height: 30)
                }
            }
            .navigationBarTitle(Text(selectedOpening.name), displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                webViewModel.shouldGoBack.toggle()
            }, label: {
                if webViewModel.canGoBack {
                    Image(systemName: "arrow.left")
                        .frame(width: 44, height: 44, alignment: .center)
                        .foregroundColor(.black)
                } else {
                    EmptyView()
                        .frame(width: 0, height: 0, alignment: .center)
                }
            })
            )

    }
}

struct BoardView_Previews: PreviewProvider{
    static var previews: some View{
        BoardView(selectedOpening: Opening(name: "test", uci: "", pgn: ""))
    }
}
