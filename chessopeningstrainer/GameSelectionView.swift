//
//  GameSelectionView.swift
//  chessopeningstrainer (iOS)
//
//  Created by Piero on 12/8/21.
//

import Foundation
import SwiftUI

struct GameSelectionView: View{
    @ObservedObject var webViewModel = WebViewModel()
        
    
    var body: some View{
        NavigationView {
            ZStack {
                WebViewContainer(webViewModel: webViewModel)
                if webViewModel.isLoading {
                    ProgressView()
                        .frame(height: 30)
                }
            }
            .navigationBarTitle(Text(webViewModel.title), displayMode: .inline)
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
}

struct GameSelectionScene_Previews: PreviewProvider{
    static var previews: some View{
        GameSelectionView()
    }
}
